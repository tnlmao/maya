package dom

import "time"

type User struct {
	UID         string `json:"uid,omitempty" gorm:"column:uid"`
	Email       string `json:"email" gorm:"column:email"`
	DisplayName string `json:"displayName,omitempty" gorm:"column:name"`
	PhotoURL    string `json:"photoURL,omitempty" gorm:"column:photoURL"`
	AccessToken string `json:"accessToken,omitempty" gorm:"column:accessToken"`
	IdToken     string `json:"idToken,omitempty" gorm:"column:idToken"`
	Password    string `json:"password,omitempty" gorm:"column:password"`
}
type DietSummary struct {
	Calories    int      `json:"calories"`
	Protein     int      `json:"protein"`
	Carbs       int      `json:"carbs"`
	Fats        int      `json:"fats"`
	Minerals    int      `json:"minerals"`
	Fibre       int      `json:"fibre"`
	Ingredients []string `json:"ingredients"`
}
type DietSummaryWithUid struct {
	Calories        int           `json:"calories" gorm:"column:calories"`
	Protein         int           `json:"protein" gorm:"column:protein"`
	Carbs           int           `json:"carbs" gorm:"column:carbs"`
	Fats            int           `json:"fats" gorm:"column:fats"`
	Minerals        int           `json:"minerals" gorm:"column:minerals"`
	Fibre           int           `json:"fibre" gorm:"column:fibre"`
	Ingredients     []Ingredients `json:"ingredients" gorm:"-"`
	IngredientsJSON string        `json:"-" gorm:"column:ingredients;type:text"`
	Uid             string        `json:"uid" gorm:"column:uid"`
	CreatedAt       time.Time     `json:"date" gorm:"column:createdAt"`
	UpdatedAt       time.Time     `json:"dateUpdatedAt" gorm:"column:updatedAt"`
}
type DietDetailsRequest struct {
	Uid  string `json:"uid"`
	Date string `json:"date"`
}
type Ingredient struct {
	Name   string  `json:"name"`
	Amount float64 `json:"amount"`
	Code   string  `json:"code"`
}
type Ingredients struct {
	Name string `json:"name"`
}
type MayaResponse struct {
	Code  int         `json:"code"`
	Msg   string      `json:"msg,omitempty"`
	Model interface{} `json:"model,omitempty"`
}
type Macro struct {
	Calories      float64 `json:"calories"`
	Protein       float64 `json:"protein"`
	Carbohydrates float64 `json:"carbs"`
	Fats          float64 `json:"fats"`
	Minerals      float64 `json:"minerals"`
	Fibre         float64 `json:"fibre"`
}
type GetDietDetails struct {
	Uid  string    `json:"uid"`
	Date time.Time `json:"date"`
}
type TodoInsert struct {
	Id        int       `json:"id" gorm:"column:id"`
	Uid       string    `json:"uid" gorm:"column:uid"`
	TodoText  string    `json:"text" gorm:"column:todoText"`
	CreatedAt time.Time `json:"date" gorm:"column:createdAt"`
	UpdatedAt time.Time `json:"dateUpdatedAt" gorm:"column:updatedAt"`
}
type TodoInsertBody struct {
	Uid      string `json:"uid"`
	TodoText string `json:"todotext"`
}
type UpdateTodo struct {
	Id        int       `json:"id" gorm:"column:id"`
	Uid       string    `json:"uid" gorm:"column:uid"`
	TodoText  string    `json:"text" gorm:"column:todoText"`
	UpdatedAt time.Time `json:"dateUpdatedAt" gorm:"column:updatedAt"`
}
type Uid struct {
	Uid string `json:"uid"`
}
type DeleteTodo struct {
	Id  int    `json:"id"`
	Uid string `json:"uid"`
}
type SaveDiaryEntry struct {
	Id        int       `json:"id" gorm:"column:id"`
	Uid       string    `json:"uid" gorm:"column:uid"`
	Title     string    `json:"title" gorm:"column:title"`
	Entry     string    `json:"entry" gorm:"column:entry"`
	CreatedAt time.Time `json:"date" gorm:"column:createdAt"`
	UpdatedAt time.Time `json:"dateUpdatedAt" gorm:"column:updatedAt"`
}
type Recipe struct {
	Title        string   `json:"title"`
	Ingredients  []string `json:"ingredients"`
	Instructions []string `json:"instructions"`
}
type Message struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type RecipeRequest struct {
	Ingredients       []string `json:"ingredients"`
	Cuisine           string   `json:"cuisine"`
	DietaryPreference string   `json:"dietaryPreference"`
}
type NewsRequest struct {
	Category []string `json:"category"`
}
type NewsResponse struct {
	Data struct {
		NewsList []struct {
			NewsObj struct {
				AuthorName     string   `json:"author_name"`
				Title          string   `json:"title"`
				ImageUrl       string   `json:"image_url"`
				ShortenedUrl   string   `json:"shortened_url"`
				Content        string   `json:"content"`
				CreatedAt      int64    `json:"created_at"`
				SourceUrl      string   `json:"source_url"`
				Category_Names []string `json:"category_names"`
			} `json:"news_obj"`
		} `json:"news_list"`
	} `json:"data"`
	Error bool `json:"error"`
}
