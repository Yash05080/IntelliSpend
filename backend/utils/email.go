package utils

import (
    "fmt"
    "net/smtp"
    "os"
)

// SendEmail sends a plain-text email
func SendEmail(to, subject, body string) error {
    host := os.Getenv("SMTP_HOST")
    port := os.Getenv("SMTP_PORT")
    user := os.Getenv("SMTP_USER")
    pass := os.Getenv("SMTP_PASS")
    from := os.Getenv("EMAIL_FROM")

    auth := smtp.PlainAuth("", user, pass, host)
    msg := []byte(
        fmt.Sprintf("From: %s\r\n", from) +
            fmt.Sprintf("To: %s\r\n", to) +
            fmt.Sprintf("Subject: %s\r\n", subject) +
            "\r\n" + body,
    )
    addr := fmt.Sprintf("%s:%s", host, port)
    return smtp.SendMail(addr, auth, from, []string{to}, msg)
}