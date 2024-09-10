package utils

import (
	"errors"
	"time"

	"maya.com/logger"
)

func DateParser(date string) (parsedDate time.Time, err error) {
	// Parse date string to time.Time
	layout := "2006-01-02"
	parsedDate, err = time.Parse(layout, date)
	if err != nil {
		logger.E("Error parsing date", err)
		err = errors.New("Error parsing date" + err.Error())
		return
	}
	logger.I("Parsed time:", parsedDate)

	return
}
