package db

import (
	"sync"

	"maya.com/core/config"
	"maya.com/logger"
	"maya.com/utils/constants"

	// "gorm.io/driver/mysql"
	// "gorm.io/gorm"
	// "maya.com/utils/constants"

	"github.com/beego/beego/orm"
	_ "github.com/go-sql-driver/mysql" // import your used driver
)

var (
	once sync.Once
	DB   orm.Ormer
)

// GetDB returns the initialized database instance
func DBInit() orm.Ormer {
	once.Do(func() {
		err := orm.RegisterDataBase(config.GetConfig(constants.Alias), config.GetConfig(constants.Driver), config.GetConfig(constants.DSN))
		if err != nil {
			logger.E("Error Registering DB")
			return
		}
		DB = orm.NewOrm()
	})
	return DB
}

// var (
// 	DB *gorm.DB
// )

// // InitializeDB initializes the database connection using the provided DSN
// func InitializeDB() (err error) {
// 	dsn := viper.Get(constants.DSN).(string)
// 	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
// 	if err != nil {
// 		return
// 	}

// 	DB = db
// 	return
// }

// // GetDB returns the initialized database instance
// func GetDB() *gorm.DB {
// 	return DB
// }

// // CloseDB closes the database connection
// func CloseDB() error {
// 	sqlDB, err := DB.DB()
// 	if err != nil {
// 		return err
// 	}
// 	return sqlDB.Close()
// }
