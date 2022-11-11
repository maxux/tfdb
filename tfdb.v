module main

import freeflowuniverse.crystallib.redisserver
import freeflowuniverse.crystallib.redisclient
import freeflowuniverse.crystallib.resp

[heap]
struct TFDBSrv {
mut:
	client redisclient.Redis
}

fn (mut t TFDBSrv) command_ping(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn (mut t TFDBSrv) command_namedefine(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) < 4 {
		return resp.r_error("Invalid arguments")
	}

	name := resp.get_array_value(input, 1)
	link := resp.get_array_value(input, 2)
	dns := resp.get_array_value(input, 3)

	if name.len < 12 {
		return resp.r_error("Name needs to be minimum 12 bytes")
	}

	return resp.r_ok()
}

fn (mut t TFDBSrv) command_groupdefine(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn (mut t TFDBSrv) command_hashdefine(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn (mut t TFDBSrv) command_groupget(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn (mut t TFDBSrv) command_hashget(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn (mut t TFDBSrv) command_hashdelete(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn (mut t TFDBSrv) command_hset(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn (mut t TFDBSrv) command_hsecure(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn (mut t TFDBSrv) command_hscan(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn (mut t TFDBSrv) command_hlen(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn (mut t TFDBSrv) command_hdel(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
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

	mut tfdb := TFDBSrv{}
	tfdb.client = redisclient.get('127.0.0.1:9900')!
	tfdb.client.ping()!

	mut h := []redisserver.RedisHandler{}
	h << redisserver.RedisHandler{
		command: 'PING'
		handler: tfdb.command_ping
	}

	h << redisserver.RedisHandler{
		command: 'NAMEDEFINE'
		handler: tfdb.command_namedefine
	}

	h << redisserver.RedisHandler{
		command: 'GROUPDEFINE'
		handler: tfdb.command_groupdefine
	}

	h << redisserver.RedisHandler{
		command: 'HASHDEFINE'
		handler: tfdb.command_hashdefine
	}

	h << redisserver.RedisHandler{
		command: 'GROUPGET'
		handler: tfdb.command_groupget
	}

	h << redisserver.RedisHandler{
		command: 'HASHGET'
		handler: tfdb.command_hashget
	}

	h << redisserver.RedisHandler{
		command: 'HASHDELETE'
		handler: tfdb.command_hashdelete
	}

	h << redisserver.RedisHandler{
		command: 'HSET'
		handler: tfdb.command_hset
	}

	h << redisserver.RedisHandler{
		command: 'HSECURE'
		handler: tfdb.command_hsecure
	}

	h << redisserver.RedisHandler{
		command: 'HSCAN'
		handler: tfdb.command_hscan
	}

	h << redisserver.RedisHandler{
		command: 'HLEN'
		handler: tfdb.command_hlen
	}

	h << redisserver.RedisHandler{
		command: 'HDEL'
		handler: tfdb.command_hdel
	}


	for {
		println('still looping...')
		mut conn := srv.socket.accept() or { continue }
		go redisserver.new_client_custom(mut conn, mut main, h)
	}

}

