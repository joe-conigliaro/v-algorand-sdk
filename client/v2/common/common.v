module common

import context
import io
import io.util as ioutil
import net.http
import net.urllib
// import github.com.algorand.go-algorand-sdk.encoding.json
// import github.com.algorand.go-algorand-sdk.encoding.msgpack
// import github.com.google.go-querystring.query
// import encoding.json
// import encoding.msgpack
// import github.com.google.go-querystring.query
import strconv
import json
import x.json2

const raw_request_paths = {
	'/v2/transactions': true
	'/v2/teal/compile': true
	'/v2/teal/dryrun':  true
}

// type BadRequest = error
// type InvalidToken = error
// type NotFound = error
// type InternalError = error

struct BadRequest { MessageError }
struct InvalidToken { MessageError }
struct NotFound { MessageError }
struct InternalError { MessageError }

pub struct Header {
mut:
	key   string
	value string
}

pub struct Client {
mut:
	server_url urllib.URL
	api_header string
	api_token  string
	headers    []&Header
}

// MakeClient is the factory for constructing a Client for a given endpo
pub fn make_client(address string, api_header string, api_token string) ?&Client {
	return &Client{
		server_url: urllib.parse(address)?
		api_header: api_header
		api_token: api_token
	}
}

// MakeClientWithHeaders is the factory for constructing a Client for a given endpoint with additional user defined head
pub fn make_client_with_headers(address string, api_header string, api_token string, headers []&Header) ?&Client {
	mut client := make_client(address, api_header, api_token)?
	client.headers << headers
	return client
}

// extractError checks if the response signifies an er
fn extract_error(code int, error_buf []u8) ? {
	if code == 200 { return }
	// wrapped_error := strconv.v_sprintf('HTTP %v: %s', code, error_buf)
	error_buf_str := error_buf.bytestr()
	wrapped_error := strconv.v_sprintf('HTTP %v: %s', code, error_buf_str)
	match code {
		400 {
			return IError(BadRequest{msg: wrapped_error})
		}
		401 {
			return IError(InvalidToken{msg: wrapped_error})
		}
		404 {
			return IError(NotFound{msg: wrapped_error})
		}
		500 {
			return IError(InternalError{msg: wrapped_error})
		}
		else {
			return error(wrapped_error)
		}
	}
}

// mergeRawQueries merges two raw queries, appending an \"&\" if both are non-e
fn merge_raw_queries(q1 string, q2 string) string {
	if q1 == '' {
		return q2
	}
	if q2 == '' {
		return q1
	}
	return q1 + '&' + q2
}

// submitFormRaw is a helper used for submitting (ex.) GETs and POSTs to the se
fn (mut client Client) submit_form_raw<T>(ctx context.Context, path string, params T, request_method http.Method, encodeJSON bool, headers_1 []&Header, body T) ?http.Response {
	mut query_url := client.server_url
	query_url.path += path
	// mut req := &http.Request{}
	// mut body_reader := io.Reader{}
	mut v := urllib.new_values()
	// params := query.values(params)
	// if params != unsafe { nil } {
	// 	v, err_2 = query.values(params)
	// 	if err_2 != unsafe { nil } {
	// 		return unsafe { nil }, err_2
	// 	}
	// }
	// if requestMethod == 'POST' && common.raw_request_paths[path] {
	// 	mut req_bytes, ok := body
	// 	if !ok {
	// 		return unsafe { nil }, error(strconv.v_sprintf("couldn't decode raw body as bytes"))
	// 	}
	// 	body_reader = bytes.new_buffer(req_bytes)
	// } else if encodeJSON {
	// 	mut json_value := json.encode(params)
	// 	body_reader = bytes.new_buffer(json_value)
	// }
	body_json := ''
	query_url.raw_query = merge_raw_queries(query_url.raw_query, v.encode())
	mut req := http.new_request(request_method, query_url.str(), body_json)?
	req.add_custom_header(client.api_header, client.api_token)?
	return req.do()
	// if err_2 != unsafe { nil } {
	// 	return unsafe { nil }, err_2
	// }
	// req.header.set(client.api_header, client.api_token)
	// for _, header in client.headers {
	// 	req.header.add(header.key, header.value)
	// }
	// for _, header_1 in headers_1 {
	// 	req.header.add(header_1.key, header_1.value)
	// }
	// mut http_client := &http.Client{}
	// // req = req.with_context(ctx)
	// // resp, err_2 = http_client.do(req)
	// resp := req.do()?
	// if err_2 != unsafe { nil } {
	// 	// NOT_YET_IMPLEMENTED
	// 	return unsafe { nil }, err_2
	// }
	// return resp, unsafe { nil }
}

fn (mut client Client) submit_form<T>(ctx_1 context.Context, path_1 string, params_1 T, request_method http.Method, encodeJSON_1 bool, headers_2 []&Header, body_1 T) ?map[string]json2.Any {
	mut resp := client.submit_form_raw(ctx_1, path_1, params_1, request_method, encodeJSON_1, headers_2, body_1)?
	// defer {
	// 	resp.body.close()
	// }
	// mut body_bytes := []u8{}
	// body_bytes = ioutil.read_all(resp.body)?
	body_bytes := resp.body

	// mut response_err := extract_error(resp.status_code, body_bytes)
	// mut str_response, ok := response
	// if ok {
	// 	*str_response = body_bytes.str()
	// 	return err_3
	// }
	// json = json.lenient_decode(body_bytes)?
	json := json2.raw_decode(body_bytes)?
	return json.as_map()
}

// Get performs a GET request to the specific path against the se
pub fn (mut client Client) get<T>(ctx_2 context.Context, path_2 string, params_2 T, headers_3 []&Header) ?map[string]json2.Any {
	return client.submit_form(ctx_2, path_2, params_2, http.Method.get, false, headers_3, unsafe { nil })
}

// GetRaw performs a GET request to the specific path against the server and returns the raw body by
pub fn (mut client Client) get_raw<T>(ctx_3 context.Context, path_3 string, params_3 T, headers_4 []&Header) ?[]u8 {
	resp_1 := client.submit_form_raw(ctx_3, path_3, params_3, http.Method.get, false, headers_4, unsafe { nil })
	defer {
		resp_1.body.close()
	}
	body_bytes := ioutil.read_all(resp_1.body)
	if err_3 != unsafe { nil } {
		return unsafe { nil }, err_3
	}
	extract_error(resp_1.status_code, body_bytes)
	return body_bytes
}

// GetRawMsgpack performs a GET request to the specific path against the server and returns the decoded messagepack respo
// pub fn (mut client Client) get_raw_msgpack<T>(ctx_4 context.Context, response_3 T, path_4 string, params_4 T, headers_5 []&Header) error {
// 	mut resp_1, err_4 := client.submit_form_raw(ctx_4, path_4, params_4, 'GET', false,
// 		headers_5, unsafe { nil })
// 	if err_4 != unsafe { nil } {
// 		return err_4
// 	}
// 	defer {
// 		resp_1.body.close()
// 	}
// 	if resp_1.status_code != http.status_ok {
// 		mut body_bytes := []u8{}
// 		body_bytes, err_4 = ioutil.read_all(resp_1.body)
// 		if err_4 != unsafe { nil } {
// 			return error(strconv.v_sprintf('failed to read response body: %+v', err_4))
// 		}
// 		return extract_error(resp_1.status_code, body_bytes)
// 	}
// 	mut dec := msgpack.new_lenient_decoder(resp_1.body)
// 	return dec.decode(&response_3)
// }

// Post sends a POST request to the given path with the given body obj
pub fn (mut client Client) post<T>(ctx_5 context.Context, response_4 T, path_5 string, params_5 T, headers_6 []&Header, body_2 T) error {
	return client.submit_form(ctx_5, response_4, path_5, params_5, http.Method.post, true, headers_6,
		body_2)
}

// Helper function for correctly formatting and escaping URL path paramet
pub fn escape_params<T>(params_6 ...T) []T {
	mut params_str := []
	{
		len:
		params_6.len
	}
	for i, param in params_6 {
		mut v := param
		match param.type_name() {
			'string' {
				params_str[i] = urllib.path_escape(v)
			}
			else {
				params_str[i] = strconv.v_sprintf('%v', v)
			}
		}
	}
	return params_str
}
