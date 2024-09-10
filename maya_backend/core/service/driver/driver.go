package driver

import (
	"context"

	"maya.com/core/dom"
)

type MayaServiceDriver interface {
	Hello(ctx context.Context) dom.MayaResponse
	CalorieCalculator(exeCtx context.Context, ingredients *[]dom.Ingredient) dom.MayaResponse
	StoreDietSummary(exeCtx context.Context, dietSummary *dom.DietSummaryWithUid) dom.MayaResponse
	Login(ctx context.Context, user *dom.User) dom.MayaResponse
	GetDietDetails(ctx context.Context, getDietDetailsRequest *dom.GetDietDetails) dom.MayaResponse
	CreateTodo(exeCtx context.Context, todo *dom.TodoInsert) dom.MayaResponse
	GetTodos(ctx context.Context, uid *dom.Uid) dom.MayaResponse
	DeleteTodos(ctx context.Context, uid *dom.DeleteTodo) dom.MayaResponse
	UpdateTodo(exeCtx context.Context, todo *dom.UpdateTodo) dom.MayaResponse
	SaveDiaryEntry(exeCtx context.Context, savediaryentry *dom.SaveDiaryEntry) dom.MayaResponse
	GetDiaryEntries(ctx context.Context, uid *dom.Uid) dom.MayaResponse
	GetRecipe(ctx context.Context, ingredients []string, cuisine string, dietaryPreference string) dom.MayaResponse
	GetNews(ctx context.Context, getNews *dom.NewsRequest) dom.MayaResponse
}
