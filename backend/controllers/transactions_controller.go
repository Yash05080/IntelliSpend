package controllers

import (
	"backend/config"
	"backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

// Create Transaction
func CreateTransaction(c *gin.Context) {
	var transaction models.Transaction
	if err := c.ShouldBindJSON(&transaction); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	config.DB.Create(&transaction)
	c.JSON(http.StatusOK, gin.H{"message": "Transaction added", "data": transaction})
}

// Get All Transactions
func GetTransactions(c *gin.Context) {
	var transactions []models.Transaction
	config.DB.Find(&transactions)
	c.JSON(http.StatusOK, transactions)
}

// Get Transaction by ID
func GetTransactionByID(c *gin.Context) {
	id := c.Param("id")
	var transaction models.Transaction

	if err := config.DB.First(&transaction, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Transaction not found"})
		return
	}

	c.JSON(http.StatusOK, transaction)
}

// Delete Transaction
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
