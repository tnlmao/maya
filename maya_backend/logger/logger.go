// Package logger contains logger related functions that are used in different packages
package logger

import (
	"fmt"
	"os"
	"path/filepath"
	"runtime"

	"github.com/rs/zerolog"
)

var defaultLogger = zerolog.New(os.Stderr).With().Timestamp().Logger()

// D ... debug logs
func D(i ...interface{}) {
	Debug(i...)
}

// I ... Info logs
func I(i ...interface{}) {

	Info(i...)
}

// E ... error logs
func E(i ...interface{}) {
	Error(i...)
}

func Print(v ...interface{}) {
	defaultLogger.Print(v...)
}
func Println(v ...interface{}) {
	defaultLogger.Println(v...)
}
func Printf(format string, v ...interface{}) {
	defaultLogger.Printf(format, v...)
}

func Debug(v ...interface{}) {
	defaultLogger.Debug().Msg(fmt.Sprint(v...))
}
func Info(v ...interface{}) {
	defaultLogger.Info().Msg(fmt.Sprint(v...))
}
func Warn(v ...interface{}) {
	defaultLogger.Warn().Msg(fmt.Sprint(v...))
}
func Error(v ...interface{}) {
	defaultLogger.Error().Msg(fmt.Sprint(v...))
}
func FuncName() string {
	skip := 1
	pc, _, _, _ := runtime.Caller(skip)
	return filepath.Base(runtime.FuncForPC(pc).Name())
}
