package controllers

import (
	"backend/config"
	"backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

// CreateTransaction now links to authenticated user
func CreateTransaction(c *gin.Context) {
    userID := c.GetUint("user_id")
    var txn models.Transaction
    if err := c.ShouldBindJSON(&txn); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }
    txn.UserID = userID
    config.DB.Create(&txn)
    c.JSON(http.StatusOK, gin.H{"message": "Transaction added", "data": txn})
}

// GetTransactions returns only this user's transactions
func GetTransactions(c *gin.Context) {
    userID := c.GetUint("user_id")
    var txns []models.Transaction
    config.DB.Where("user_id = ?", userID).Find(&txns)
    c.JSON(http.StatusOK, txns)
}

// Other handlers (Get by ID, Delete) similarly filter by user_id

func GetTransactionByID(c *gin.Context) {
	id := c.Param("id")
	var transaction models.Transaction

	if err := config.DB.First(&transaction, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Transaction not found"})
		return
	}

	c.JSON(http.StatusOK, transaction)
}

func DeleteTransaction(c *gin.Context) {
	id := c.Param("id")
	var transaction models.Transaction

	if err := config.DB.First(&transaction, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Transaction not found"})
		return
	}

	config.DB.Delete(&transaction)
	c.JSON(http.StatusOK, gin.H{"message": "Transaction deleted"})
}
