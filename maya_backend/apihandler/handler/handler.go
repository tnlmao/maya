package handler

import (
	"context"
	"encoding/json"
	"io"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/pkg/errors"
	"maya.com/core/dom"
	"maya.com/core/service/driver"
	"maya.com/logger"
	"maya.com/utils"
	"maya.com/utils/constants"
)

func Hello(mayadriver driver.MayaServiceDriver) gin.HandlerFunc {

	logger.I(constants.Inside + logger.FuncName())
	var exeCtx context.Context
	return func(c *gin.Context) {
		exeCtx = context.Background()
		responseData := mayadriver.Hello(exeCtx)
		c.JSON(http.StatusOK, responseData)
	}
}
func Login(mayadriver driver.MayaServiceDriver) gin.HandlerFunc {
	logger.I(constants.Inside + logger.FuncName())
	var exeCtx context.Context
	return func(c *gin.Context) {
		exeCtx = context.Background()
		body, err := io.ReadAll(c.Request.Body)
		if err != nil {
			logger.E(logger.FuncName(), err)
			c.JSON(http.StatusInternalServerError, constants.RequestReadingError)
		}
		logger.I(constants.RequestRecieved, string(body))
		user := &dom.User{}
		err = json.Unmarshal(body, user)
		if err != nil {
			err = errors.Wrap(err, logger.FuncName())
			logger.E(logger.FuncName(), constants.UnmarshalError, err)
			c.JSON(http.StatusBadRequest, constants.InvalidRequest)
			return
		}
		responseData := mayadriver.Login(exeCtx, user)
		c.JSON(http.StatusOK, responseData)
	}
}
func CalorieCalculatorHandler(mayadriver driver.MayaServiceDriver) gin.HandlerFunc {
	logger.I(constants.Inside + logger.FuncName())
	var exeCtx context.Context
	return func(c *gin.Context) {
		exeCtx = context.Background()
		body, err := io.ReadAll(c.Request.Body)
		if err != nil {
			logger.E(logger.FuncName(), err)
			c.JSON(http.StatusInternalServerError, constants.RequestReadingError)
		}
		logger.I(constants.RequestRecieved, string(body))

		ingredients := &[]dom.Ingredient{}
		err = json.Unmarshal(body, ingredients)
		if err != nil {
			err = errors.Wrap(err, logger.FuncName())
			logger.E(logger.FuncName(), constants.UnmarshalError, err)
			c.JSON(200, constants.InvalidRequest)
			return
		}
		responseData := mayadriver.CalorieCalculator(exeCtx, ingredients)
		c.JSON(http.StatusOK, responseData)
	}
}
func StoreDietSummaryHandler(mayadriver driver.MayaServiceDriver) gin.HandlerFunc {
	logger.I(constants.Inside + logger.FuncName())
	var exeCtx context.Context
	return func(c *gin.Context) {
		exeCtx = context.Background()
		body, err := io.ReadAll(c.Request.Body)
		if err != nil {
			logger.E(logger.FuncName(), err)
			c.JSON(http.StatusInternalServerError, constants.RequestReadingError)
		}
		logger.I(constants.RequestRecieved, string(body))

		dietSummary := &dom.DietSummaryWithUid{}
		err = json.Unmarshal(body, dietSummary)
		if err != nil {
			err = errors.Wrap(err, logger.FuncName())
			logger.E(logger.FuncName(), constants.UnmarshalError, err)
			c.JSON(200, constants.InvalidRequest)
			return
		}
		responseData := mayadriver.StoreDietSummary(exeCtx, dietSummary)
		c.JSON(http.StatusOK, responseData)
	}
}
func GetDietDetails(mayadriver driver.MayaServiceDriver) gin.HandlerFunc {
	logger.I(constants.Inside + logger.FuncName())
	var exeCtx context.Context
	return func(c *gin.Context) {
		exeCtx = context.Background()
		body, err := io.ReadAll(c.Request.Body)
		if err != nil {
			logger.E(logger.FuncName(), err)
			c.JSON(http.StatusInternalServerError, constants.RequestReadingError)
			return
		}

		logger.I(constants.RequestRecieved, string(body))

		req := &dom.DietDetailsRequest{}
		if err := json.Unmarshal(body, req); err != nil {
			logger.E(logger.FuncName(), constants.UnmarshalError, err)
			c.JSON(http.StatusBadRequest, constants.InvalidRequest)
			return
		}
		parsedTime, err := utils.DateParser(req.Date)
		if err != nil {
			logger.E(logger.FuncName(), err)
			c.JSON(http.StatusBadRequest, constants.InvalidRequest)
			return
		}
		dietDetailsRequest := &dom.GetDietDetails{
			Uid:  req.Uid,
			Date: parsedTime,
		}

		responseData := mayadriver.GetDietDetails(exeCtx, dietDetailsRequest)
		c.JSON(http.StatusOK, responseData)
	}
}
func CreateTodo(mayadriver driver.MayaServiceDriver) gin.HandlerFunc {
	logger.I(constants.Inside + logger.FuncName())
	var exeCtx context.Context
	return func(c *gin.Context) {
		exeCtx = context.Background()
		body, err := io.ReadAll(c.Request.Body)
		if err != nil {
			logger.E(logger.FuncName(), err)
			c.JSON(http.StatusInternalServerError, constants.RequestReadingError)
		}
		logger.I(constants.RequestRecieved, string(body))

		addTodo := &dom.TodoInsert{}
		err = json.Unmarshal(body, addTodo)
		if err != nil {
			err = errors.Wrap(err, logger.FuncName())
			logger.E(logger.FuncName(), constants.UnmarshalError, err)
			c.JSON(200, constants.InvalidRequest)
			return
		}
		logger.I(addTodo)
		responseData := mayadriver.CreateTodo(exeCtx, addTodo)
		c.JSON(http.StatusCreated, responseData)
	}
}
func GetTodos(mayadriver driver.MayaServiceDriver) gin.HandlerFunc {
	logger.I(constants.Inside + logger.FuncName())
	var exeCtx context.Context
	return func(c *gin.Context) {
		exeCtx = context.Background()
		uid := c.Query(constants.Uid)
		if uid == constants.EmptySpace {
			logger.E(logger.FuncName(), constants.QueryParamsMissingError)
			c.JSON(http.StatusBadRequest, constants.QueryParamsMissingError)
			return
		}
		logger.I(constants.RequestRecieved, uid)

		getTodo := &dom.Uid{Uid: uid}
		responseData := mayadriver.GetTodos(exeCtx, getTodo)
		c.JSON(http.StatusOK, responseData)
	}
}
func DeleteTodos(mayadriver driver.MayaServiceDriver) gin.HandlerFunc {
	logger.I(constants.Inside + logger.FuncName())
	var exeCtx context.Context
	return func(c *gin.Context) {
		exeCtx = context.Background()
		body, err := io.ReadAll(c.Request.Body)
		if err != nil {
			logger.E(logger.FuncName(), err)
			c.JSON(http.StatusInternalServerError, constants.RequestReadingError)
		}

		logger.I(constants.RequestRecieved, string(body))
		deleteTodo := &dom.DeleteTodo{}
		err = json.Unmarshal(body, deleteTodo)
		if err != nil {
			err = errors.Wrap(err, logger.FuncName())
			logger.E(logger.FuncName(), constants.UnmarshalError, err)
			c.JSON(200, constants.InvalidRequest)
			return
		}
		logger.I(deleteTodo)
		responseData := mayadriver.DeleteTodos(exeCtx, deleteTodo)
		c.JSON(http.StatusNoContent, responseData)
	}
}
func UpdateTodo(mayadriver driver.MayaServiceDriver) gin.HandlerFunc {
	logger.I(constants.Inside + logger.FuncName())
	var exeCtx context.Context
	return func(c *gin.Context) {
		exeCtx = context.Background()
		body, err := io.ReadAll(c.Request.Body)
		if err != nil {
			logger.E(logger.FuncName(), err)
			c.JSON(http.StatusInternalServerError, constants.RequestReadingError)
			return
		}
		logger.I(constants.RequestRecieved, string(body))

		updateTodo := &dom.UpdateTodo{}
		err = json.Unmarshal(body, updateTodo)
		if err != nil {
			err = errors.Wrap(err, logger.FuncName())
			logger.E(logger.FuncName(), constants.UnmarshalError, err)
			c.JSON(http.StatusBadRequest, constants.InvalidRequest)
			return
		}
		logger.I(updateTodo)

		// Call your service to update the todo
		responseData := mayadriver.UpdateTodo(exeCtx, updateTodo)
		c.JSON(http.StatusOK, responseData)
	}
}

func SaveDiaryEntry(mayadriver driver.MayaServiceDriver) gin.HandlerFunc {
	logger.I(constants.Inside + logger.FuncName())
	var exeCtx context.Context
	return func(c *gin.Context) {
		exeCtx = context.Background()
		body, err := io.ReadAll(c.Request.Body)
		if err != nil {
			logger.E(logger.FuncName(), err)
			c.JSON(http.StatusInternalServerError, constants.RequestReadingError)
		}
		logger.I(constants.RequestRecieved, string(body))

		savediaryentry := &dom.SaveDiaryEntry{}
		err = json.Unmarshal(body, savediaryentry)
		if err != nil {
			err = errors.Wrap(err, logger.FuncName())
			logger.E(logger.FuncName(), constants.UnmarshalError, err)
			c.JSON(200, constants.InvalidRequest)
			return
		}
		logger.I(savediaryentry)
		responseData := mayadriver.SaveDiaryEntry(exeCtx, savediaryentry)
		c.JSON(http.StatusCreated, responseData)
	}
}
func GetDiaryEntries(mayadriver driver.MayaServiceDriver) gin.HandlerFunc {
	logger.I(constants.Inside + logger.FuncName())
	var exeCtx context.Context
	return func(c *gin.Context) {
		exeCtx = context.Background()
		uid := c.Query(constants.Uid)
		if uid == "" {
			logger.E(logger.FuncName(), constants.QueryParamsMissingError)
			c.JSON(http.StatusBadRequest, constants.QueryParamsMissingError)
			return
		}
		logger.I(constants.RequestRecieved, uid)

		getTodo := &dom.Uid{Uid: uid}
		responseData := mayadriver.GetDiaryEntries(exeCtx, getTodo)
		c.JSON(http.StatusOK, responseData)
	}
}
func GetRecipe(mayadriver driver.MayaServiceDriver) gin.HandlerFunc {
	logger.I(constants.Inside + logger.FuncName())
	var exeCtx context.Context
	return func(c *gin.Context) {
		exeCtx = context.Background()
		body, err := io.ReadAll(c.Request.Body)
		if err != nil {
			logger.E(logger.FuncName(), err)
			c.JSON(http.StatusInternalServerError, constants.RequestReadingError)
			return
		}

		logger.I(constants.RequestRecieved, string(body))

		req := &dom.RecipeRequest{}
		if err := json.Unmarshal(body, req); err != nil {
			logger.E(logger.FuncName(), constants.UnmarshalError, err)
			c.JSON(http.StatusBadRequest, constants.InvalidRequest)
			return
		}
		// Collect ingredient names from query parameters

		responseData := mayadriver.GetRecipe(exeCtx, req.Ingredients, req.Cuisine, req.DietaryPreference)
		c.JSON(http.StatusOK, responseData)
	}
}
func GetNews(mayadriver driver.MayaServiceDriver) gin.HandlerFunc {
	logger.I(constants.Inside + logger.FuncName())
	var exeCtx context.Context
	return func(c *gin.Context) {
		exeCtx = context.Background()
		body, err := io.ReadAll(c.Request.Body)
		if err != nil {
			logger.E(logger.FuncName(), err)
			c.JSON(http.StatusInternalServerError, constants.RequestReadingError)
			return
		}

		logger.I(constants.RequestRecieved, string(body))
		getNews := &dom.NewsRequest{}
		if err := json.Unmarshal(body, getNews); err != nil {
			logger.E(logger.FuncName(), constants.UnmarshalError, err)
			c.JSON(http.StatusBadRequest, constants.InvalidRequest)
			return
		}
		logger.I(constants.RequestRecieved, getNews)

		responseData := mayadriver.GetNews(exeCtx, getNews)
		c.JSON(http.StatusOK, responseData)
	}
}
