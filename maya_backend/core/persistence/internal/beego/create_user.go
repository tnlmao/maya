package beego

import (
	"maya.com/core/dom"
	. "mayamodels.com"
)

type BeegoUser struct{}

func (b *BeegoUser) CreateUser(u *dom.User) (err error) {
	e := convertDomainToModel(u)
	return new(User).CreateUser(e)
}
func convertDomainToModel(u *dom.User) *User {
	return &User{
		UID:         u.UID,
		Email:       u.Email,
		FirstName:   u.FirstName,
		LastName:    u.LastName,
		PhotoURL:    u.PhotoURL,
		AccessToken: u.AccessToken,
		IdToken:     u.IdToken,
		Password:    u.Password,
	}
}
