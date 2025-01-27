package mayapersistence

import (
	"maya.com/core/persistence/driver"
	"maya.com/core/persistence/mysql"
)

func MayaPersistence(layerType string) *driver.MayaPersistence {
	switch layerType {
	case "mysql":
		return mysql.NewMayaPersistence()
	case "mock":
		// return mock.NewAgentManagementAgentPersistenceMock()
	}

	return nil
}
