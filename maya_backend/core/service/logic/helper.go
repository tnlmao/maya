package logic

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"maya.com/core/dom"
	"maya.com/logger"
	"maya.com/utils/db"
)

func GetDietSummary(ingredients []dom.Ingredient) (*dom.DietSummary, error) {
	summary := &dom.DietSummary{}
	//var macro *dom.Macro
	for _, ingredient := range ingredients {
		macro, err := FetchIngredientData(ingredient.Code)
		if err != nil {
			return &dom.DietSummary{}, err
		}
		summary.Calories += int(float64(macro.Calories) * ingredient.Amount / 100.0)
		summary.Protein += int(float64(macro.Protein) * ingredient.Amount / 100.0)
		summary.Carbs += int(float64(macro.Carbohydrates) * ingredient.Amount / 100.0)
		summary.Fats += int(float64(macro.Fats) * ingredient.Amount / 100.0)
		summary.Minerals += int(float64(macro.Minerals) * ingredient.Amount / 100.0)
		summary.Fibre += int(float64(macro.Fibre) * ingredient.Amount / 100.0)
		summary.Ingredients = append(summary.Ingredients, ingredient.Name)
	}
	fmt.Println(summary.Calories)
	return summary, nil
}

func FetchIngredientData(code string) (*dom.Macro, error) {

	dbi := db.GetDB()
	var macro dom.Macro
	err := dbi.Select("calories, protein, carbohydrates, fats, minerals, fibre").Where("code = ?", code).First(&macro).Error
	if err != nil {
		fmt.Println("Error fetching data:", err)
		return nil, err
	}
	return &dom.Macro{
		Calories:      macro.Calories,
		Protein:       macro.Protein,
		Carbohydrates: macro.Carbohydrates,
		Fats:          macro.Fats,
		Minerals:      macro.Minerals,
		Fibre:         macro.Fibre,
	}, nil
}

func StoreDietSummaryInDb(ctx context.Context, dietSummary *dom.DietSummaryWithUid) (result bool, err error) {
	dbi := db.GetDB()

	ingredientsJSON, err := json.Marshal(dietSummary.Ingredients)
	if err != nil {
		logger.E("Error marshaling ingredients: ", err)
		return false, err
	}
	dietSummary.CreatedAt = time.Now().In(time.FixedZone("IST", 5*3600+30*60))
	dietSummary.UpdatedAt = time.Now().In(time.FixedZone("IST", 5*3600+30*60))

	// Store the JSON string in IngredientsJSON field
	dietSummary.IngredientsJSON = string(ingredientsJSON)
	if err = dbi.Create(dietSummary).Error; err != nil {
		result = false
		logger.E("failed to insert diet summary || ", err)
		return
	}
	result = true
	return
}
func AggregateNutrition(periodMap map[string]int, detail dom.DietSummaryWithUid) {
	periodMap["calories"] += detail.Calories
	periodMap["protein"] += detail.Protein
	periodMap["carbs"] += detail.Carbs
	periodMap["fats"] += detail.Fats
	periodMap["fibre"] += detail.Fibre
	periodMap["minerals"] += detail.Minerals
}

func ParseRecipe(response string) dom.Recipe {
	sections := strings.Split(response, "\n\n")

	title := strings.TrimPrefix(sections[0], "Title: ")

	ingredientsSection := strings.Split(sections[1], "\n")[1:]
	instructionsSection := strings.Split(sections[2], "\n")[1:]

	ingredients := make([]string, len(ingredientsSection))
	for i, ingredient := range ingredientsSection {
		ingredients[i] = strings.TrimPrefix(ingredient, fmt.Sprintf("%d. ", i+1))
	}

	instructions := make([]string, len(instructionsSection))
	for i, instruction := range instructionsSection {
		instructions[i] = strings.TrimPrefix(instruction, fmt.Sprintf("%d. ", i+1))
	}

	return dom.Recipe{
		Title:        title,
		Ingredients:  ingredients,
		Instructions: instructions,
	}
}
