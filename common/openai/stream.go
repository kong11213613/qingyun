package openai

import (
	"errors"
)

var (
	ErrTooManyEmptyStreamMessages = errors.New("stream has sent too many empty messages")
)
