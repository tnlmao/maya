package app

import (
	"context"
	"encoding/json"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	ginadapter "github.com/awslabs/aws-lambda-go-api-proxy/gin"
	"github.com/beego/beego/v2/client/orm"
	"github.com/gin-gonic/gin"
	"maya.com/core/config"
	"maya.com/logger"
	constants "maya.com/utils/constants"
)

type App struct {
	Router *gin.Engine
	// SQSRouter          *awsrouter.SQSRouter
	// SNSRouter          *awsrouter.SNSRouter
	// WebsocketRouter    *awsrouter.WebsocketRouter
	ApplicationName string
	// InvokeLambdaRouter *awsrouter.InvokeLambdaRouter
}

var ginLambda *ginadapter.GinLambda

func New(appName string) *App {
	return &App{
		Router:          gin.Default(),
		ApplicationName: appName,
	}
}
func (a *App) Init() {
	config.SetEnv()
	// if err := db.DBInit(); err != nil {
	// 	logger.E(constants.DBConnectivityError, err)
	// 	panic(err)
	// }
}
func (a *App) StartHandler() {
	lambda.Start(a.Handler)
}

func (a *App) Handler(ctx context.Context, input map[string]interface{}) (interface{}, error) {
	logger.I(constants.Inside + logger.FuncName())
	inputBytes, _ := json.Marshal(input)
	var awsAPIGatewayEvent events.APIGatewayProxyRequest

	err := json.Unmarshal(inputBytes, &awsAPIGatewayEvent)
	if err == nil && awsAPIGatewayEvent.HTTPMethod != "" {
		awsEvent := awsAPIGatewayEvent
		ginLambda = ginadapter.New(a.Router)
		return ginLambda.ProxyWithContext(ctx, awsEvent)
	}
	return constants.InvalidRequest, err
}
func (a *App) PostOp() {
	inst, err := orm.GetDB(config.GetConfig(constants.Alias))
	if err != nil {
		return
	}
	inst.Close()
}
