package apihandler

import (
	"github.com/gin-gonic/gin"
	"maya.com/apihandler/handler"
	"maya.com/core/config"
	"maya.com/core/persistence/mayapersistence"
	"maya.com/core/service/logic"
	"maya.com/middleware"
)

func SetupRoutes(engine *gin.Engine) {
	mayaPersistence := mayapersistence.MayaPersistence("mysql")
	mayaSvc := logic.MayaServiceSvc(mayaPersistence)

	// engine.Use(func(c *gin.Context) {
	// 	c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
	// 	c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
	// 	c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type")
	// 	c.Next()
	// })
	router := engine.Group(config.GetApiStageName())
	router.Use(middleware.DBConnectionMiddleware)
	//Test Route
	engine.GET("/default/hello", handler.Hello(mayaSvc))

	//Login Auth Route
	engine.POST("/default/login", handler.Login(mayaSvc))

	//Health Routes
	engine.POST("/default/calorie", handler.CalorieCalculatorHandler(mayaSvc))
	engine.POST("/default/storedietsummary", handler.StoreDietSummaryHandler(mayaSvc))
	engine.POST("/default/getdietdetails", handler.GetDietDetails(mayaSvc))

	//List Routes
	engine.POST("/default/createtodo", handler.CreateTodo(mayaSvc))
	engine.GET("/default/gettodos", handler.GetTodos(mayaSvc))
	engine.DELETE("/default/deletetodos", handler.DeleteTodos(mayaSvc))
	engine.PUT("/default/updatetodo", handler.UpdateTodo(mayaSvc))

	//Diary Routes
	engine.POST("/default/savediaryentry", handler.SaveDiaryEntry(mayaSvc))
	engine.GET("/default/getdiaryentries", handler.GetDiaryEntries(mayaSvc))

	//Recipe Routes
	engine.POST("/default/getrecipe", handler.GetRecipe(mayaSvc))

	//News
	engine.POST("/default/getnews", handler.GetNews(mayaSvc))
}
