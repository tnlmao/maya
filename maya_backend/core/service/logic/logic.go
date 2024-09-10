package logic

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"strings"
	"time"

	"github.com/google/generative-ai-go/genai"
	"github.com/google/uuid"
	"google.golang.org/api/option"
	"maya.com/core/dom"
	"maya.com/core/service/driver"
	"maya.com/logger"
	"maya.com/utils/constants"
	"maya.com/utils/db"
)

type MayaService struct {
}

func MayaServiceSvc() driver.MayaServiceDriver {
	return &MayaService{}
}
func (m *MayaService) Hello(ctx context.Context) dom.MayaResponse {

	return dom.MayaResponse{
		Code: 200,
		Msg:  "Hello, I am working Fine!!",
	}
}
func (m *MayaService) Login(ctx context.Context, user *dom.User) (response dom.MayaResponse) {
	db := db.GetDB()
	// Check if the user already exists
	if result := db.First(&user, "email = ?", user.Email); result.Error == nil {
		logger.I("User Already Registered")
		return
	}
	// User Creation
	result := db.Create(&user)
	if result.Error != nil {
		logger.I("Error while inserting user")
		response.Code = http.StatusInternalServerError
		response.Msg = result.Error.Error()
	}
	response.Code = 200
	response.Msg = "true"
	return
}
func (m *MayaService) CalorieCalculator(ctx context.Context, ingredients *[]dom.Ingredient) (response dom.MayaResponse) {

	summary, err := GetDietSummary(*ingredients)
	if err != nil {
		logger.E("Error fetching diet summary: ", err)
		return
	}
	response.Code = 200
	response.Msg = "true"
	response.Model = summary
	return
}
func (m *MayaService) StoreDietSummary(ctx context.Context, dietSummary *dom.DietSummaryWithUid) (response dom.MayaResponse) {
	result, err := StoreDietSummaryInDb(ctx, dietSummary)
	if err != nil {
		logger.E("Error storing Diet Summary || ", err)
	}
	if result {
		response = dom.MayaResponse{
			Code: 200,
			Msg:  "true",
		}
	}
	return
}
func (m *MayaService) GetDietDetails(ctx context.Context, getDietDetailsRequest *dom.GetDietDetails) (response dom.MayaResponse) {
	logger.I("Inside GetDietDetails in logic ")
	var dietDetails []dom.DietSummaryWithUid
	dbi := db.GetDB()
	logger.I("Got db instance ", dbi)
	logger.I("uid , date  ", dbi)
	uid := getDietDetailsRequest.Uid
	date := getDietDetailsRequest.Date
	logger.I("uid   ", uid)
	logger.I("date  ", date)
	//fmt.Printf("%#+v", dbi)
	// Perform query to fetch diet details for the specified date and user ID
	query := fmt.Sprintf("SELECT * FROM diet_summary_with_uids WHERE uid = '%s' AND DATE(createdAt) = '%s'", uid, date)
	//, getDietDetailsRequest.Uid, getDietDetailsRequest.Date
	result := dbi.Raw(query).Scan(&dietDetails)
	if result.Error != nil {
		logger.E("Error fetching diet details || ", result.Error)
		return
	}
	logger.I("Number of diet details found:", result.RowsAffected)
	logger.I("dietDetails after db call  ", dietDetails)
	// Initialize map to store aggregated nutrition values for each time period
	dietDetailsMap := map[string]map[string]int{
		"breakfast": {"calories": 0, "protein": 0, "carbs": 0, "fats": 0, "fibre": 0, "minerals": 0},
		"brunch":    {"calories": 0, "protein": 0, "carbs": 0, "fats": 0, "fibre": 0, "minerals": 0},
		"lunch":     {"calories": 0, "protein": 0, "carbs": 0, "fats": 0, "fibre": 0, "minerals": 0},
		"snack":     {"calories": 0, "protein": 0, "carbs": 0, "fats": 0, "fibre": 0, "minerals": 0},
		"dinner":    {"calories": 0, "protein": 0, "carbs": 0, "fats": 0, "fibre": 0, "minerals": 0},
		"supper":    {"calories": 0, "protein": 0, "carbs": 0, "fats": 0, "fibre": 0, "minerals": 0},
	}
	logger.I("dietDetails:", dietDetails)
	//fmt.Printf("%#+v", dietDetails)
	// Iterate through diet details and aggregate nutrition values
	for _, detail := range dietDetails {
		// Determine time period based on created_at time
		hour := detail.CreatedAt.Hour()
		switch {
		case hour >= 6 && hour < 11:
			AggregateNutrition(dietDetailsMap["breakfast"], detail)
		case hour >= 11 && hour < 13:
			AggregateNutrition(dietDetailsMap["brunch"], detail)
		case hour >= 13 && hour < 16:
			AggregateNutrition(dietDetailsMap["lunch"], detail)
		case hour >= 16 && hour < 18:
			AggregateNutrition(dietDetailsMap["snack"], detail)
		case hour >= 18 && hour < 23:
			AggregateNutrition(dietDetailsMap["dinner"], detail)
		default:
			AggregateNutrition(dietDetailsMap["supper"], detail)
		}
	}

	// Convert aggregated map to JSON
	dietDetailsJSON, err := json.Marshal(dietDetailsMap)
	if err != nil {
		logger.E("Error marshaling diet details to JSON || ", err)
		return
	}
	logger.I("dietDetailsJSON:", string(dietDetailsJSON))
	response.Code = 200
	response.Msg = "true"
	response.Model = dietDetailsMap
	return response
}
func (m *MayaService) CreateTodo(exeCtx context.Context, todo *dom.TodoInsert) (response dom.MayaResponse) {
	dbi := db.GetDB()

	todo.CreatedAt = time.Now().In(time.FixedZone("IST", 5*3600+30*60))
	todo.UpdatedAt = time.Now().In(time.FixedZone("IST", 5*3600+30*60))

	if err := dbi.Create(todo).Error; err != nil {
		logger.E("failed to insert todo || ", err)
		return
	}

	response = dom.MayaResponse{
		Code: 201,
		Msg:  "Todo Created",
	}
	return
}
func (m *MayaService) GetTodos(exeCtx context.Context, uid *dom.Uid) (response dom.MayaResponse) {
	dbi := db.GetDB()
	var result []dom.TodoInsert
	err := dbi.Select("id, todoText").Where("uid = ?", uid.Uid).Find(&result).Error
	if err != nil {
		logger.E("Error fetching data:", err)
		return
	}
	logger.I(result)
	response = dom.MayaResponse{
		Code:  200,
		Msg:   "Todo List",
		Model: result,
	}
	return
}
func (m *MayaService) DeleteTodos(ctx context.Context, deleteTodo *dom.DeleteTodo) (response dom.MayaResponse) {
	dbi := db.GetDB()
	if err := dbi.Where("id = ? AND uid = ?", deleteTodo.Id, deleteTodo.Uid).Delete(&dom.TodoInsert{}).Error; err != nil {
		logger.E("Error deleting data from todos", err)
		return
	}
	return dom.MayaResponse{
		Code: 204,
		Msg:  "Deleted",
	}
}
func (m *MayaService) SaveDiaryEntry(exeCtx context.Context, savediaryentry *dom.SaveDiaryEntry) (response dom.MayaResponse) {
	dbi := db.GetDB()

	savediaryentry.CreatedAt = time.Now().In(time.FixedZone("IST", 5*3600+30*60))
	savediaryentry.UpdatedAt = time.Now().In(time.FixedZone("IST", 5*3600+30*60))

	if err := dbi.Create(savediaryentry).Error; err != nil {
		logger.E("failed to insert diary entry || ", err)
		return
	}

	response = dom.MayaResponse{
		Code: 201,
		Msg:  "Todo Created",
	}
	return
}
func (m *MayaService) GetDiaryEntries(ctx context.Context, uid *dom.Uid) (response dom.MayaResponse) {
	dbi := db.GetDB()
	var result []dom.SaveDiaryEntry
	err := dbi.Select("id, title,entry,createdAt,updatedAt").Where("uid = ?", uid.Uid).Find(&result).Error
	if err != nil {
		logger.E("Error fetching data:", err)
		return
	}
	logger.I(result)
	response = dom.MayaResponse{
		Code:  200,
		Msg:   "Todo List",
		Model: result,
	}
	return
}
func (m *MayaService) GetRecipe(ctx context.Context, ingredients []string, cuisine string, dietaryPreference string) (response dom.MayaResponse) {
	//ctx := context.Background()
	// Access your API key as an environment variable (see "Set up your API key" above)
	client, err := genai.NewClient(ctx, option.WithAPIKey("AIzaSyBPLQiA_dOPH1Zecn-X5TzIPdUL7AAVW6o"))
	if err != nil {
		log.Fatal(err)
	}
	defer client.Close()

	// The Gemini 1.5 models are versatile and work with both text-only and multimodal prompts
	model := client.GenerativeModel("gemini-1.5-flash")
	//ing1 := "rice, soyabean"
	ingredientsStr := strings.Join(ingredients, ", ")
	format := `Title: [Recipe Title]

Ingredients:
 [Ingredient 1]
 [Ingredient 2]
 [Ingredient 3]
...
Instructions:
 [Instruction 1]
 [Instruction 2]
 [Instruction 3]
...
`
	resp, err := model.GenerateContent(ctx, genai.Text(`Generate a detailed recipe with the following format:`+format+`. Ensure the response does not include any additional spaces, new lines, symbols or formatting, such as stars or other characters and strictly follows the format exactly as specified.`)+" Ingredients provided are "+genai.Text(ingredientsStr)+". Preffered cooking style is: "+genai.Text(cuisine)+" and Dietary Preference is "+genai.Text(dietaryPreference)+". Follow all the instructions above without any mistake and strictly follow the format.")
	if err != nil {
		log.Fatal(err)
	}
	var builder strings.Builder
	for _, part := range resp.Candidates[0].Content.Parts {
		if text, ok := part.(genai.Text); ok {
			builder.WriteString(string(text))
		}
	}

	result := builder.String()
	fmt.Println(result)

	parts := strings.Split(result, "\n\n")

	// Initialize the Recipe struct
	var recipe dom.Recipe

	// Loop through the sections and fill the struct
	for _, part := range parts {
		fmt.Println(part)
		lines := strings.Split(part, "\n")
		if len(lines) > 0 {
			if strings.HasPrefix(lines[0], "Title:") {
				recipe.Title = strings.TrimSpace(strings.TrimPrefix(lines[0], "Title:"))
			} else if strings.HasPrefix(lines[0], "Ingredients:") {
				for _, line := range lines[1:] {
					if line != "" {
						recipe.Ingredients = append(recipe.Ingredients, strings.TrimSpace(line))
					}
				}
			} else if strings.HasPrefix(lines[0], "Instructions:") {
				for _, line := range lines[1:] {
					if line != "" {
						recipe.Instructions = append(recipe.Instructions, strings.TrimSpace(line))
					}
				}
			}
		}
	}

	// Marshal the struct into JSON
	jsonData, err := json.MarshalIndent(recipe, "", "  ")
	if err != nil {
		fmt.Println("Error marshaling JSON:", err)
		return
	}

	// Print the JSON string
	fmt.Println(string(jsonData))

	response = dom.MayaResponse{
		Code:  200,
		Msg:   "Recipe",
		Model: recipe,
	}
	return
}
func (m *MayaService) UpdateTodo(exeCtx context.Context, todo *dom.UpdateTodo) (response dom.MayaResponse) {
	todo.UpdatedAt = time.Now().In(time.FixedZone("IST", 5*3600+30*60))
	dbi := db.GetDB()
	query := `
        UPDATE todo_inserts
        SET todoText = ?, updatedAt = ?
        WHERE id = ? AND uid = ?
    `

	// Execute the update query
	result := dbi.Exec(query, todo.TodoText, todo.UpdatedAt, todo.Id, todo.Uid)
	if result.Error != nil {
		logger.E("Error updating todo || ", result.Error)
		return
	}
	return dom.MayaResponse{
		Code: 200,
		Msg:  "true",
	}
}
func (m *MayaService) GetNews(ctx context.Context, getNews *dom.NewsRequest) (response dom.MayaResponse) {
	//url := constants.BaseURL
	client := &http.Client{}
	newsArray := make([]map[string]interface{}, 0)
	uniqueCategories := make(map[string]struct{})

	// Function to make the API call and process the response
	fetchNewsForCategory := func(category string) error {
		var url string
		if category == "all_news" {
			url = fmt.Sprintf("%s/news?category=%s&max_limit=300&include_card_data=true", constants.BaseURL, constants.CategoryAll)
		} else {
			url = fmt.Sprintf("%s/search/%s/%s&max_limit=100", constants.BaseURL, constants.CategoryTop, category)
		}

		req, err := http.NewRequest("GET", url, nil)
		if err != nil {
			return err
		}

		req.Header.Set("User-Agent", constants.UserAgent)
		req.Header.Set("Accept", "*/*")
		req.Header.Set("Content-Type", "application/json")
		req.Header.Set("Referer", "https://inshorts.com/en/read")

		resp, err := client.Do(req)
		if err != nil {
			return err
		}
		defer resp.Body.Close()

		body, err := io.ReadAll(resp.Body)
		if err != nil {
			return err
		}

		var newsResponse dom.NewsResponse
		err = json.Unmarshal(body, &newsResponse)
		if err != nil {
			return err
		}

		newsData := newsResponse.Data.NewsList
		if len(newsData) == 0 {
			return fmt.Errorf("newsData nil")
		}

		for _, entry := range newsData {
			news := entry.NewsObj
			for _, category := range news.Category_Names {
				uniqueCategories[category] = struct{}{}
			}
			timestamp := time.Unix(news.CreatedAt/1000, 0).UTC()
			ist := timestamp.In(time.FixedZone("Asia/Kolkata", 5*3600+30*60))
			date := ist.Format("Monday, 02 January, 2006")
			timeStr := ist.Format("03:04 pm")

			newsObject := map[string]interface{}{
				"id":          uuid.New().String(),
				"title":       news.Title,
				"imageUrl":    news.ImageUrl,
				"url":         news.ShortenedUrl,
				"content":     news.Content,
				"author":      news.AuthorName,
				"date":        date,
				"time":        timeStr,
				"readMoreUrl": news.SourceUrl,
			}
			newsArray = append(newsArray, newsObject)
		}
		return nil
	}

	// Iterate over each category and fetch the news
	for _, category := range getNews.Category {
		if err := fetchNewsForCategory(category); err != nil {
			logger.E("Error fetching news for category", category, err)
			response.Code = 500
			response.Msg = err.Error()
			return
		}
	}

	// If 'all_news' is in the category list, also return the categories
	if getNews.Category[0] == "all_news" {
		var categories []string
		for category := range uniqueCategories {
			categories = append(categories, category)
		}
		return dom.MayaResponse{
			Code: 200,
			Msg:  "true",
			Model: map[string]interface{}{
				"categories": categories,
				"data":       newsArray,
			},
		}
	}

	return dom.MayaResponse{
		Code: 200,
		Msg:  "true",
		Model: map[string]interface{}{
			"data": newsArray,
		},
	}
}
