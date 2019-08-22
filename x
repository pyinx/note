| API | zkCli命令 | 说明 | 操作类型 | 创建watcher |
| ---- | ---- | ---- | ---- | ---- | ---- | 
| CONNECT  | connect | 连接zk服务 | 写 | 否 |
| CREATE | create | 创建znode节点 | 写 | 否 |
| CREATE2 |  | 创建znote节点 | 写 | 否 |
| DELETE  | delete/rmr | 删除znode节点 | 写 | 否 |
| EXISTS |  | 判断znode节点是否存在 | 读 | 否 |
| EXISTS_W |  | 判断znode节点是否存在 | 读 | 是 |
| GETDATA | get | 获取znode的值 | 读 | 否 |
| GETDATA_W | get | 获取znode的值 | 读 | 是 |
| SETDATA | set | 变更znote的值 | 写 | 否 |
| GETACL | getAcl | 获取znode的ACL | 读 | 否 |
| SETACL | setAcl | 变更znode的ACL | 写 | 否 |
| SETAUTH | addauth | 设置权限 | 写 | 否 |
| GETCHILDREN | ls | 获取znode的子节点列表 | 读 | 否 |
| GETCHILDREN_W | ls | 获取znode的子节点列表 | 读 | 是 |
| GETCHILDREN2 | ls2 | 获取znode的子节点列表 | 读 | 否 |
| GETCHILDREN2_W | ls2 | 获取znode的子节点列表 | 读 | 是 |
| SYNC | sync | 同步znode的数据 | 读 | 是 |
| CLOSE | close/quit | 关闭连接 | 写 | 否 |
| PING |  | 心跳探测 | 读 | 否 |
| MULTI |  | 批量执行多个命令 | - | - |
