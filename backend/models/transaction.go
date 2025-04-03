package models

import "gorm.io/gorm"

type Transaction struct {
	gorm.Model
	Title       string  `json:"title"`
	Amount      float64 `json:"amount"`
	Category    string  `json:"category"`
	TransactionType string `json:"transaction_type"` // "income" or "expense"
}
