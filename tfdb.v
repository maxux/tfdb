module main

import freeflowuniverse.crystallib.redisserver
import freeflowuniverse.crystallib.resp2

fn command_ping(input resp2.RValue, mut _ redisserver.RedisInstance) resp2.RValue {
	if resp2.get_redis_array_len(input) > 1 {
		return resp2.get_redis_array(input)[1]
	}

	return resp2.r_string('PONG')
}

fn main() {
	mut srv := redisserver.listen('0.0.0.0', 5555) or {
		panic("Can't Listen on port with error: $err")
	}

	mut main := &redisserver.RedisInstance{}

	mut h := []redisserver.RedisHandler{}
	h << redisserver.RedisHandler{
		command: 'PING'
		handler: command_ping
	}

	for {
		println('still looping...')
		mut conn := srv.socket.accept() or { continue }
		go redisserver.new_client_custom(mut conn, mut main, h)
	}

}

