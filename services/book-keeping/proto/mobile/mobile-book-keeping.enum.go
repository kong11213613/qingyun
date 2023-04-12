// Code generated by microctl. If you need edit, delete this line

package mobile_book_keeping

var StatusCodeMsgMap = map[StatusCode]string{
	StatusCode_status_success:        "请求成功",
	StatusCode_status_internal_error: "内部错误",
	StatusCode_status_param_error:    "参数错误",
	StatusCode_status_has_bill_error: "存在账单",
}

func (x StatusCode) ErrMsg() string {
	msg, ok := StatusCodeMsgMap[x]
	if ok {
		return msg
	}
	return ""
}

func ServiceStatus(status *Status, statusCode StatusCode) {
	status.Code = statusCode
	status.Msg = statusCode.ErrMsg()
}
func Msg(v interface{}) string {
	switch v.(type) {
	}
	return ""
}
