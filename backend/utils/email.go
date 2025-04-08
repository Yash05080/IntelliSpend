package utils

import (
	"fmt"
	"net/smtp"
	"os"
)

func SendEmail(to, subject, body string) error {
	from := os.Getenv("EMAIL_FROM")
	password := os.Getenv("EMAIL_PASS")

	// Debug log the email details (remove sensitive info in production)
	fmt.Println("Attempting to send email from:", from, "to:", to)
	
	msg := "From: " + from + "\n" +
		"To: " + to + "\n" +
		"Subject: " + subject + "\n\n" +
		body

	auth := smtp.PlainAuth("", from, password, "smtp.gmail.com")
	
	err := smtp.SendMail("smtp.gmail.com:587", auth, from, []string{to}, []byte(msg))
	if err != nil {
		fmt.Println("❌ Email sending failed:", err)
		return err
	}

	fmt.Println("✅ OTP Email sent to:", to)
	return nil
}
