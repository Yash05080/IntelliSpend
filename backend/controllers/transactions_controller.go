package controllers

import (
	"backend/config"
	"backend/models"
	
	"net/http"

	"github.com/gin-gonic/gin"
)

// CreateTransaction creates a new transaction linked to the authenticated user.
func CreateTransaction(c *gin.Context) {
	// Get authenticated user_id (set by your JWT middleware)
	userID := c.GetUint("user_id")
	var txn models.Transaction
	if err := c.ShouldBindJSON(&txn); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	txn.UserID = userID

	if err := config.DB.Create(&txn).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create transaction"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Transaction added", "data": txn})
}

// GetTransactions returns only the transactions of the authenticated user.
func GetTransactions(c *gin.Context) {
	userID := c.GetUint("user_id")
	var txns []models.Transaction

	if err := config.DB.Where("user_id = ?", userID).Find(&txns).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve transactions"})
		return
	}

	c.JSON(http.StatusOK, txns)
}

// GetTransactionByID returns a single transaction if it belongs to the authenticated user.
func GetTransactionByID(c *gin.Context) {
	userID := c.GetUint("user_id")
	id := c.Param("id")
	var txn models.Transaction

	if err := config.DB.Where("id = ? AND user_id = ?", id, userID).First(&txn).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Transaction not found"})
		return
	}

	c.JSON(http.StatusOK, txn)
}

// DeleteTransaction deletes a transaction if it belongs to the authenticated user.
func DeleteTransaction(c *gin.Context) {
	userID := c.GetUint("user_id")
	id := c.Param("id")
	var txn models.Transaction

	if err := config.DB.Where("id = ? AND user_id = ?", id, userID).First(&txn).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Transaction not found"})
		return
	}

	if err := config.DB.Delete(&txn).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete transaction"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Transaction deleted"})
}
