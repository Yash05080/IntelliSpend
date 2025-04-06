package routes

import (
    "backend/controllers"
    "backend/middleware"
    "github.com/gin-gonic/gin"
)

func SetupRoutes(router *gin.Engine) {
    auth := router.Group("/auth")
    {
        auth.POST("/register", controllers.Register)
        auth.POST("/verify", controllers.Verify)
        // later: auth.POST("/google", controllers.GoogleAuth)
    }

    // Protected transaction routes
    txn := router.Group("/transactions")
    txn.Use(middleware.AuthRequired())
    {
        txn.POST("/", controllers.CreateTransaction)
        txn.GET("/", controllers.GetTransactions)
        txn.GET("/:id", controllers.GetTransactionByID)
        txn.DELETE("/:id", controllers.DeleteTransaction)
    }
}