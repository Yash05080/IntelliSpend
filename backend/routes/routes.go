package routes

import (
	"github.com/gin-gonic/gin"
	"backend/controllers"
)

func RegisterRoutes(router *gin.Engine) {
	router.POST("/auth/google", controllers.GoogleAuth)
}
