package driver

import "maya.com/core/dom"

type MayaPersistence struct {
	UserPersistence User
}

type User interface {
	CreateUser(user *dom.User) (err error)
}
