module main

import freeflowuniverse.crystallib.redisserver
import freeflowuniverse.crystallib.resp

fn command_ping(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
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

	h << redisserver.RedisHandler{
		command: 'NAMEDEFINE'
		handler: command_ping
	}

	h << redisserver.RedisHandler{
		command: 'GROUPDEFINE'
		handler: command_ping
	}

	h << redisserver.RedisHandler{
		command: 'HASHDEFINE'
		handler: command_ping
	}

	h << redisserver.RedisHandler{
		command: 'CIRCLEGET'
		handler: command_ping
	}

	h << redisserver.RedisHandler{
		command: 'HASHGET'
		handler: command_ping
	}

	h << redisserver.RedisHandler{
		command: 'HASHDELETE'
		handler: command_ping
	}

	h << redisserver.RedisHandler{
		command: 'HSET'
		handler: command_ping
	}

	h << redisserver.RedisHandler{
		command: 'HSECURE'
		handler: command_ping
	}

	h << redisserver.RedisHandler{
		command: 'HSCAN'
		handler: command_ping
	}

	h << redisserver.RedisHandler{
		command: 'HLEN'
		handler: command_ping
	}

	h << redisserver.RedisHandler{
		command: 'HDEL'
		handler: command_ping
	}


	for {
		println('still looping...')
		mut conn := srv.socket.accept() or { continue }
		go redisserver.new_client_custom(mut conn, mut main, h)
	}

}

