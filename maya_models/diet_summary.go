package mayamodels

type DietSummary struct {
	Id          int      `orm:"column(id);auto" json:"id"`
	Calories    int      `orm:"column(calories)" json:"calories"`
	Protein     int      `orm:"column(protein)" json:"protein"`
	Carbs       int      `orm:"column(carbs)" json:"carbs"`
	Fats        int      `orm:"column(fats)" json:"fats"`
	Minerals    int      `orm:"column(minerals)" json:"minerals"`
	Fibre       int      `orm:"column(fibre)" json:"fibres"`
	Ingredients []string `orm:"column(ingredients)" json:"ingredients"`
}

func (d *DietSummary) TableName() string {
	return "diet_summary"
}
