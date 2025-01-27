package middleware

import "github.com/gin-gonic/gin"

func DBConnectionMiddleware(c *gin.Context) {

	c.Next()
}
