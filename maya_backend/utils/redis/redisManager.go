package redis

// import (
// 	"context"

// 	"github.com/go-redis/redis/v8"
// 	"maya.com/logger"
// )

// var _redisClient *redis.Client

// func GetRedisClient(ctx context.Context) *redis.Client {
// 	if _redisClient == nil {
// 		_redisClient = redis.NewClient(&redis.Options{
// 			Addr:     "redis-12987.c305.ap-south-1-1.ec2.redns.redis-cloud.com:12987", // e.g., "localhost:6379"
// 			Password: "NmgBATDzjd5FlHBEeZaEoK8dVyGWqlTe",                              // leave blank if no password
// 			DB:       0,
// 		})

// 		// Test the connection
// 		if err := _redisClient.Ping(ctx).Err(); err != nil {
// 			logger.E("redis.ConnectToRedis", err)
// 			return nil
// 		}
// 		logger.I("redis.ConnectToRedis", "Redis connection established")
// 	}

// 	return _redisClient
//}
