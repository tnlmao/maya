package mayamodels

import (
	"time"

	"github.com/beego/beego/orm"
)

type User struct {
	UID         string    `orm:"column(uid);auto" json:"uid"`
	Email       string    `orm:"column(email)" json:"email"`
	FirstName   string    `orm:"column(firstname)" json:"firstname"`
	LastName    string    `orm:"column(lastname)" json:"lastname"`
	PhotoURL    string    `orm:"column(photourl)" json:"photourl"`
	AccessToken string    `orm:"column(accesstoken)" json:"accesstoken"`
	IdToken     string    `orm:"column(idtoken)" json:"idtoken"`
	Password    string    `orm:"column(password)" json:"password"`
	CreatedOn   time.Time `orm:"column(createdon);type(datetime);null;auto_now_add"`
	UpdatedOn   time.Time `orm:"column(updatedon);type(datetime);null;auto_now"`
}

func init() {
	orm.RegisterModel(new(User))
}

func (u *User) CreateUser(user *User) (err error) {
	return nil
}
func (u *User) TableName() string {
	return "users"
}
