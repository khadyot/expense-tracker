package com.expensetracker.expense_tracker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.SmsMessage
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*
import java.util.regex.Pattern

class SmsReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "SmsReceiver"
        var methodChannel: MethodChannel? = null
        
        // Common transaction patterns for Indian banks
        private val TRANSACTION_PATTERNS = listOf(
            // Pattern 1: "Rs 1,234.56 debited from A/c XX1234 on 24-01-26 to MERCHANT"
            Pattern.compile(
                """(?:Rs\.?|INR)\s*([0-9,]+(?:\.[0-9]{2})?)\s*(?:debited|spent|paid).*?(?:on|at)\s*(\d{2}-\d{2}-\d{2,4}).*?(?:to|at)\s*([A-Z0-9\s]+)""",
                Pattern.CASE_INSENSITIVE
            ),
            // Pattern 2: "Your A/c XX1234 debited by Rs 1234.56 on 24Jan26 for MERCHANT"
            Pattern.compile(
                """debited\s+by\s+(?:Rs\.?|INR)\s*([0-9,]+(?:\.[0-9]{2})?)\s*on\s*(\d{2}[A-Za-z]{3}\d{2,4})\s*(?:for|at)\s*([A-Z0-9\s]+)""",
                Pattern.CASE_INSENSITIVE
            ),
            // Pattern 3: "Spent Rs 1234.56 at MERCHANT on 24/01/2026"
            Pattern.compile(
                """(?:spent|paid)\s+(?:Rs\.?|INR)\s*([0-9,]+(?:\.[0-9]{2})?)\s*at\s*([A-Z0-9\s]+)\s*on\s*(\d{2}/\d{2}/\d{2,4})""",
                Pattern.CASE_INSENSITIVE
            )
        )
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != "android.provider.Telephony.SMS_RECEIVED") return

        val bundle = intent.extras ?: return
        val pdus = bundle.get("pdus") as? Array<*> ?: return
        
        for (pdu in pdus) {
            val message = SmsMessage.createFromPdu(pdu as ByteArray)
            val messageBody = message.messageBody
            val sender = message.originatingAddress ?: "Unknown"
            
            Log.d(TAG, "SMS from $sender: $messageBody")
            
            // Try to parse transaction
            val transaction = parseTransaction(messageBody)
            if (transaction != null) {
                Log.d(TAG, "Parsed transaction: $transaction")
                sendToFlutter(transaction)
            }
        }
    }

    private fun parseTransaction(sms: String): JSONObject? {
        for (pattern in TRANSACTION_PATTERNS) {
            val matcher = pattern.matcher(sms)
            if (matcher.find()) {
                try {
                    val amount = matcher.group(1)?.replace(",", "")?.toDouble() ?: continue
                    val dateStr = matcher.group(2) ?: ""
                    val merchant = matcher.group(3)?.trim() ?: "Unknown"
                    
                    val transaction = JSONObject()
                    transaction.put("amount", amount)
                    transaction.put("merchant", merchant)
                    transaction.put("date", parseDate(dateStr))
                    transaction.put("source", "sms")
                    transaction.put("rawSms", sms)
                    
                    return transaction
                } catch (e: Exception) {
                    Log.e(TAG, "Error parsing transaction", e)
                }
            }
        }
        return null
    }

    private fun parseDate(dateStr: String): String {
        val formats = listOf(
            SimpleDateFormat("dd-MM-yy", Locale.getDefault()),
            SimpleDateFormat("dd-MM-yyyy", Locale.getDefault()),
            SimpleDateFormat("ddMMMyy", Locale.getDefault()),
            SimpleDateFormat("dd/MM/yyyy", Locale.getDefault())
        )
        
        for (format in formats) {
            try {
                val date = format.parse(dateStr)
                if (date != null) {
                    return SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(date)
                }
            } catch (e: Exception) {
                // Try next format
            }
        }
        
        // Default to today if parsing fails
        return SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
    }

    private fun sendToFlutter(transaction: JSONObject) {
        methodChannel?.invokeMethod("onSmsTransaction", transaction.toString())
    }
}
