package models

import "gorm.io/gorm"

// Transaction represents an expense or income record
type Transaction struct {
    gorm.Model
    Name        string  `json:"name"`
    TotalAmount float64 `json:"totalamount"`
    Date        string  `json:"date"`
    Description string  `json:"description"`
    Category    string  `json:"category"`
    Type        string  `json:"type"` // "income" or "expense"

    UserID      uint    `json:"userId"` // FK to users
}