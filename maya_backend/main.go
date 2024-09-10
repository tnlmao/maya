package main

import (
	_ "github.com/go-sql-driver/mysql"
	"maya.com/apihandler"
	"maya.com/core/app"
)

func main() {
	application := app.New("maya")
	application.Init()
	apihandler.SetupRoutes(application.Router)
	application.StartHandler()
}
