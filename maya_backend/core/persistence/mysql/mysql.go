package mysql

import (
	"maya.com/core/persistence/driver"
	"maya.com/core/persistence/internal/beego"
)

func UserPersistence() driver.User {
	return &beego.BeegoUser{}
}
func NewMayaPersistence() *driver.MayaPersistence {
	return &driver.MayaPersistence{
		UserPersistence: UserPersistence(),
	}
}
