package config

import (
	"fmt"
	"os"
	"strings"

	"github.com/spf13/viper"
)

var AppConfig *viper.Viper

func SetEnv() {
	AppConfig = viper.New()

	vars := os.Environ()

	for _, env := range vars {

		pair := strings.SplitN(env, "=", 2)
		key := pair[0]
		value := pair[1]
		fmt.Printf("Key: %s, Value: %s\n", key, value)
		AppConfig.Set(key, value)
	}
}
func GetConfig(key string) (configStr string) {
	config := AppConfig.Get(key)
	return config.(string)
}

func SetConfig(key string, value any) {
	AppConfig.Set(key, value)
}
func GetApiStageName() string {
	apiStageName := AppConfig.Get("api_stage_name")
	return apiStageName.(string)
}
