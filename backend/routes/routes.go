package routes

import (
	"backend/controllers"
	"backend/middleware"

	"github.com/gin-gonic/gin"
)

// SetupRoutes configures API endpoints.
func SetupRoutes(router *gin.Engine) {
	// Auth endpoints under /api/auth
	auth := router.Group("/api/auth")
	{
		auth.POST("/register", controllers.Register)       // Registration endpoint
		auth.POST("/verify-otp", controllers.VerifyOTP)      // OTP verification endpoint
		auth.POST("/login", controllers.Login)               // Login endpoint
	}

	// Transaction endpoints under /api/transactions, protected by Auth middleware.
	txn := router.Group("/api/transactions")
	txn.Use(middleware.AuthRequired())
	{
		txn.POST("/", controllers.CreateTransaction)         // Create a new transaction
		txn.GET("/", controllers.GetTransactions)            // Get all transactions for the user
		txn.GET("/:id", controllers.GetTransactionByID)      // Get a transaction by ID
		txn.DELETE("/:id", controllers.DeleteTransaction)    // Delete a transaction by ID
	}
}
