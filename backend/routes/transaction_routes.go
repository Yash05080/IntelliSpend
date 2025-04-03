package routes

import (
	"backend/controllers"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(router *gin.Engine) {
	router.POST("/transactions", controllers.CreateTransaction)
	router.GET("/transactions", controllers.GetTransactions)
	router.GET("/transactions/:id", controllers.GetTransactionByID)
	router.DELETE("/transactions/:id", controllers.DeleteTransaction)
}
