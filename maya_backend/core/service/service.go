package service

import "maya.com/core/dom"

func MayaResponse(code int, Msg string, model interface{}) dom.MayaResponse {
	return dom.MayaResponse{
		Code:  code,
		Msg:   Msg,
		Model: model,
	}
}
