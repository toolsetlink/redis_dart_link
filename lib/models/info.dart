part of models;

/// Info
class Info {
  /// 服务器信息
  final ServerInfo server;

  /// 客户端信息
  final ClientsInfo clients;

  /// 内存信息
  final MemoryInfo memory;

  /// 持久化信息
  final PersistenceInfo persistence;

  /// 统计信息
  final StatsInfo stats;

  /// 复制信息
  final ReplicationInfo replication;

  /// CPU 使用信息
  final CPUInfo cpu;

  /// 集群信息
  final ClusterInfo cluster;

  /// 键空间信息
  final KeyspaceInfo keyspace;

  /// Info
  Info({
    required this.server,
    required this.clients,
    required this.memory,
    required this.persistence,
    required this.stats,
    required this.replication,
    required this.cpu,
    required this.cluster,
    required this.keyspace,
  });

  factory Info.fromMap(Map<String, String> map) {
    return Info(
      server: ServerInfo.fromMap(map),
      clients: ClientsInfo.fromMap(map),
      memory: MemoryInfo.fromMap(map),
      persistence: PersistenceInfo.fromMap(map),
      stats: StatsInfo.fromMap(map),
      replication: ReplicationInfo.fromMap(map),
      cpu: CPUInfo.fromMap(map),
      cluster: ClusterInfo.fromMap(map),
      keyspace: KeyspaceInfo.fromMap(map),
    );
  }

  factory Info.fromResult(Object reqResult) {
    Map<String, String> infoMap = {};

    if (reqResult is RespType2<dynamic>) {
      final bulkString = reqResult.toBulkString().payload;
      if (bulkString != null) {
        List<String> result = bulkString
            .split('\n')
            .where((e) => e.isNotEmpty)
            .toList(growable: false);

        for (String line in result) {
          // 忽略空行和以 # 开头的行（节名）
          if (line.isEmpty || line.startsWith('#')) {
            continue;
          }

          // 分割属性行到键值对
          int delimiterIndex = line.indexOf(':');
          if (delimiterIndex != -1) {
            String key = line.substring(0, delimiterIndex);
            String value = line.substring(delimiterIndex + 1);
            infoMap[key] = value;
          }
        }
      }
    } else if (reqResult is RespType3<dynamic>) {
      final bulkString = reqResult.toBulkString().payload;
      if (bulkString != null) {
        List<String> result = bulkString
            .split('\n')
            .where((e) => e.isNotEmpty)
            .toList(growable: false);

        for (String line in result) {
          // 忽略空行和以 # 开头的行（节名）
          if (line.isEmpty || line.startsWith('#')) {
            continue;
          }

          // 分割属性行到键值对
          int delimiterIndex = line.indexOf(':');
          if (delimiterIndex != -1) {
            String key = line.substring(0, delimiterIndex);
            String value = line.substring(delimiterIndex + 1);
            infoMap[key] = value;
          }
        }
      }
    }

    return Info(
      server: ServerInfo.fromMap(infoMap),
      clients: ClientsInfo.fromMap(infoMap),
      memory: MemoryInfo.fromMap(infoMap),
      persistence: PersistenceInfo.fromMap(infoMap),
      stats: StatsInfo.fromMap(infoMap),
      replication: ReplicationInfo.fromMap(infoMap),
      cpu: CPUInfo.fromMap(infoMap),
      cluster: ClusterInfo.fromMap(infoMap),
      keyspace: KeyspaceInfo.fromMap(infoMap),
    );
  }
}

/// ServerInfo
class ServerInfo {
  /// Redis 版本
  final String redisVersion;

  /// Git SHA1
  final String redisGitSha1;

  /// Git 仓库是否有未提交的修改
  final bool redisGitDirty;

  /// 构建 ID
  final String redisBuildId;

  /// Redis 运行模式（例如 standalone）
  final String redisMode;

  /// 操作系统
  final String os;

  /// 架构位数（32 或 64）
  final int archBits;

  /// 多路复用 API
  final String multiplexingApi;

  /// 原子变量 API
  final String atomicvarApi;

  /// GCC 编译器版本
  final String gccVersion;

  /// 当前 Redis 服务器的进程 ID
  final int processId;

  /// Redis 服务器的运行 ID
  final String runId;

  /// TCP 连接的端口
  final int tcpPort;

  /// Redis 已运行的时间（秒）
  final int uptimeInSeconds;

  /// Redis 已运行的时间（天）
  final int uptimeInDays;

  /// Redis 每秒进行的调度次数
  final int hz;

  /// 服务器的 LRU 时钟
  final int lruClock;

  /// Redis 可执行文件的路径
  final String executable;

  /// 配置文件的路径
  final String configFile;

  /// ServerInfo
  ServerInfo({
    required this.redisVersion,
    required this.redisGitSha1,
    required this.redisGitDirty,
    required this.redisBuildId,
    required this.redisMode,
    required this.os,
    required this.archBits,
    required this.multiplexingApi,
    required this.atomicvarApi,
    required this.gccVersion,
    required this.processId,
    required this.runId,
    required this.tcpPort,
    required this.uptimeInSeconds,
    required this.uptimeInDays,
    required this.hz,
    required this.lruClock,
    required this.executable,
    required this.configFile,
  });

  /// fromMap
  factory ServerInfo.fromMap(Map<String, String> map) {
    return ServerInfo(
      redisVersion: map['redis_version'] ?? '',
      redisGitSha1: map['redis_git_sha1'] ?? '',
      redisGitDirty: map['redis_git_dirty'] == '1',
      redisBuildId: map['redis_build_id'] ?? '',
      redisMode: map['redis_mode'] ?? '',
      os: map['os'] ?? '',
      archBits: int.parse(map['arch_bits'] ?? '0'),
      multiplexingApi: map['multiplexing_api'] ?? '',
      atomicvarApi: map['atomicvar_api'] ?? '',
      gccVersion: map['gcc_version'] ?? '',
      processId: int.parse(map['process_id'] ?? '0'),
      runId: map['run_id'] ?? '',
      tcpPort: int.parse(map['tcp_port'] ?? '0'),
      uptimeInSeconds: int.parse(map['uptime_in_seconds'] ?? '0'),
      uptimeInDays: int.parse(map['uptime_in_days'] ?? '0'),
      hz: int.parse(map['hz'] ?? '0'),
      lruClock: int.parse(map['lru_clock'] ?? '0'),
      executable: map['executable'] ?? '',
      configFile: map['config_file'] ?? '',
    );
  }
}

/// ClientsInfo
class ClientsInfo {
  /// 已连接的客户端数量
  final int connectedClients;

  /// 客户端输出列表最长的长度
  final int clientLongestOutputList;

  /// 客户端输入缓存区最大的长度
  final int clientBiggestInputBuf;

  /// 被阻塞的客户端数量
  final int blockedClients;

  /// ClientsInfo
  ClientsInfo({
    required this.connectedClients,
    required this.clientLongestOutputList,
    required this.clientBiggestInputBuf,
    required this.blockedClients,
  });

  /// fromMap
  factory ClientsInfo.fromMap(Map<String, String> map) {
    return ClientsInfo(
      connectedClients: int.parse(map['connected_clients'] ?? '0'),
      clientLongestOutputList:
          int.parse(map['client_longest_output_list'] ?? '0'),
      clientBiggestInputBuf: int.parse(map['client_biggest_input_buf'] ?? '0'),
      blockedClients: int.parse(map['blocked_clients'] ?? '0'),
    );
  }
}

/// MemoryInfo
class MemoryInfo {
  /// 已使用内存
  final int usedMemory;

  /// 已使用内存（人类可读格式）
  final String usedMemoryHuman;

  /// 已使用内存的常驻集大小（RSS）
  final int usedMemoryRss;

  /// 已使用RSS（人类可读格式）
  final String usedMemoryRssHuman;

  /// 内存使用峰值
  final int usedMemoryPeak;

  /// 内存使用峰值（人类可读格式）
  final String usedMemoryPeakHuman;

  /// 内存使用峰值百分比
  final String usedMemoryPeakPerc;

  /// 内存开销
  final int usedMemoryOverhead;

  /// 启动时的内存使用量
  final int usedMemoryStartup;

  /// 数据集的内存使用量
  final int usedMemoryDataset;

  /// 数据集的内存使用百分比
  final String usedMemoryDatasetPerc;

  /// 系统总内存
  final int totalSystemMemory;

  /// 系统总内存（人类可读格式）
  final String totalSystemMemoryHuman;

  /// Lua 脚本引擎的内存使用量
  final int usedMemoryLua;

  /// Lua 脚本引擎的内存使用量（人类可读格式）
  final String usedMemoryLuaHuman;

  /// 配置的最大内存容量
  final int maxMemory;

  /// 最大内存容量（人类可读格式）
  final String maxMemoryHuman;

  /// 内存淘汰策略
  final String maxMemoryPolicy;

  /// 内存碎片率
  final double memFragmentationRatio;

  /// 内存分配器
  final String memAllocator;

  /// 是否正在进行主动内存碎片整理
  final int activeDefragRunning;

  /// 待释放的对象数量
  final int lazyfreePendingObjects;

  /// MemoryInfo
  MemoryInfo({
    required this.usedMemory,
    required this.usedMemoryHuman,
    required this.usedMemoryRss,
    required this.usedMemoryRssHuman,
    required this.usedMemoryPeak,
    required this.usedMemoryPeakHuman,
    required this.usedMemoryPeakPerc,
    required this.usedMemoryOverhead,
    required this.usedMemoryStartup,
    required this.usedMemoryDataset,
    required this.usedMemoryDatasetPerc,
    required this.totalSystemMemory,
    required this.totalSystemMemoryHuman,
    required this.usedMemoryLua,
    required this.usedMemoryLuaHuman,
    required this.maxMemory,
    required this.maxMemoryHuman,
    required this.maxMemoryPolicy,
    required this.memFragmentationRatio,
    required this.memAllocator,
    required this.activeDefragRunning,
    required this.lazyfreePendingObjects,
  });

  /// fromMap
  factory MemoryInfo.fromMap(Map<String, String> map) {
    return MemoryInfo(
      usedMemory: int.parse(map['used_memory'] ?? '0'),
      usedMemoryHuman: map['used_memory_human'] ?? '',
      usedMemoryRss: int.parse(map['used_memory_rss'] ?? '0'),
      usedMemoryRssHuman: map['used_memory_rss_human'] ?? '',
      usedMemoryPeak: int.parse(map['used_memory_peak'] ?? '0'),
      usedMemoryPeakHuman: map['used_memory_peak_human'] ?? '',
      usedMemoryPeakPerc: map['used_memory_peak_perc'] ?? '',
      usedMemoryOverhead: int.parse(map['used_memory_overhead'] ?? '0'),
      usedMemoryStartup: int.parse(map['used_memory_startup'] ?? '0'),
      usedMemoryDataset: int.parse(map['used_memory_dataset'] ?? '0'),
      usedMemoryDatasetPerc: map['used_memory_dataset_perc'] ?? '',
      totalSystemMemory: int.parse(map['total_system_memory'] ?? '0'),
      totalSystemMemoryHuman: map['total_system_memory_human'] ?? '',
      usedMemoryLua: int.parse(map['used_memory_lua'] ?? '0'),
      usedMemoryLuaHuman: map['used_memory_lua_human'] ?? '',
      maxMemory: int.parse(map['maxmemory'] ?? '0'),
      maxMemoryHuman: map['maxmemory_human'] ?? '',
      maxMemoryPolicy: map['maxmemory_policy'] ?? '',
      memFragmentationRatio:
          double.parse(map['mem_fragmentation_ratio'] ?? '0.0'),
      memAllocator: map['mem_allocator'] ?? '',
      activeDefragRunning: int.parse(map['active_defrag_running'] ?? '0'),
      lazyfreePendingObjects: int.parse(map['lazyfree_pending_objects'] ?? '0'),
    );
  }
}

/// PersistenceInfo
class PersistenceInfo {
  /// 是否正在载入 RDB 文件
  final int loading;

  /// 自上次保存以来的变更次数
  final int rdbChangesSinceLastSave;

  /// 是否正在进行 RDB 后台保存
  final int rdbBgsaveInProgress;

  /// 上次成功保存 RDB 的时间戳
  final int rdbLastSaveTime;

  /// 上次 RDB 后台保存的状态
  final String rdbLastBgsaveStatus;

  /// 上次 RDB 后台保存耗时（秒）
  final int rdbLastBgsaveTimeSec;

  /// 当前 RDB 后台保存耗时（秒）
  final int rdbCurrentBgsaveTimeSec;

  /// 上次 RDB 写时复制大小
  final int rdbLastCowSize;

  /// 是否启用 AOF
  final int aofEnabled;

  /// 是否正在进行 AOF 重写
  final int aofRewriteInProgress;

  /// 是否计划进行 AOF 重写
  final int aofRewriteScheduled;

  /// 上次 AOF 重写耗时（秒）
  final int aofLastRewriteTimeSec;

  /// 当前 AOF 重写耗时（秒）
  final int aofCurrentRewriteTimeSec;

  /// 上次 AOF 后台重写状态
  final String aofLastBgrewriteStatus;

  /// 上次 AOF 写入状态
  final String aofLastWriteStatus;

  /// 上次 AOF 写时复制大小
  final int aofLastCowSize;

  /// 当前 AOF 文件大小
  final int aofCurrentSize;

  /// AOF 基础大小
  final int aofBaseSize;

  /// 待处理的 AOF 重写数量
  final int aofPendingRewrite;

  /// AOF 缓冲区长度
  final int aofBufferLength;

  /// AOF 重写缓冲区长度
  final int aofRewriteBufferLength;

  /// 待处理的 AOF BIO 同步数量
  final int aofPendingBioFsync;

  /// 延迟的 AOF 同步数量
  final int aofDelayedFsync;

  /// PersistenceInfo
  PersistenceInfo({
    required this.loading,
    required this.rdbChangesSinceLastSave,
    required this.rdbBgsaveInProgress,
    required this.rdbLastSaveTime,
    required this.rdbLastBgsaveStatus,
    required this.rdbLastBgsaveTimeSec,
    required this.rdbCurrentBgsaveTimeSec,
    required this.rdbLastCowSize,
    required this.aofEnabled,
    required this.aofRewriteInProgress,
    required this.aofRewriteScheduled,
    required this.aofLastRewriteTimeSec,
    required this.aofCurrentRewriteTimeSec,
    required this.aofLastBgrewriteStatus,
    required this.aofLastWriteStatus,
    required this.aofLastCowSize,
    required this.aofCurrentSize,
    required this.aofBaseSize,
    required this.aofPendingRewrite,
    required this.aofBufferLength,
    required this.aofRewriteBufferLength,
    required this.aofPendingBioFsync,
    required this.aofDelayedFsync,
  });

  /// fromMap
  factory PersistenceInfo.fromMap(Map<String, String> map) {
    return PersistenceInfo(
      loading: int.parse(map['loading'] ?? '0'),
      rdbChangesSinceLastSave:
          int.parse(map['rdb_changes_since_last_save'] ?? '0'),
      rdbBgsaveInProgress: int.parse(map['rdb_bgsave_in_progress'] ?? '0'),
      rdbLastSaveTime: int.parse(map['rdb_last_save_time'] ?? '0'),
      rdbLastBgsaveStatus: map['rdb_last_bgsave_status'] ?? '',
      rdbLastBgsaveTimeSec: int.parse(map['rdb_last_bgsave_time_sec'] ?? '0'),
      rdbCurrentBgsaveTimeSec:
          int.parse(map['rdb_current_bgsave_time_sec'] ?? '-1'),
      rdbLastCowSize: int.parse(map['rdb_last_cow_size'] ?? '0'),
      aofEnabled: int.parse(map['aof_enabled'] ?? '0'),
      aofRewriteInProgress: int.parse(map['aof_rewrite_in_progress'] ?? '0'),
      aofRewriteScheduled: int.parse(map['aof_rewrite_scheduled'] ?? '0'),
      aofLastRewriteTimeSec: int.parse(map['aof_last_rewrite_time_sec'] ?? '0'),
      aofCurrentRewriteTimeSec:
          int.parse(map['aof_current_rewrite_time_sec'] ?? '-1'),
      aofLastBgrewriteStatus: map['aof_last_bgrewrite_status'] ?? '',
      aofLastWriteStatus: map['aof_last_write_status'] ?? '',
      aofLastCowSize: int.parse(map['aof_last_cow_size'] ?? '0'),
      aofCurrentSize: int.parse(map['aof_current_size'] ?? '0'),
      aofBaseSize: int.parse(map['aof_base_size'] ?? '0'),
      aofPendingRewrite: int.parse(map['aof_pending_rewrite'] ?? '0'),
      aofBufferLength: int.parse(map['aof_buffer_length'] ?? '0'),
      aofRewriteBufferLength:
          int.parse(map['aof_rewrite_buffer_length'] ?? '0'),
      aofPendingBioFsync: int.parse(map['aof_pending_bio_fsync'] ?? '0'),
      aofDelayedFsync: int.parse(map['aof_delayed_fsync'] ?? '0'),
    );
  }
}

/// StatsInfo
class StatsInfo {
  /// 已接收的连接总数
  final int totalConnectionsReceived;

  /// 已处理的命令总数
  final int totalCommandsProcessed;

  /// 每秒瞬时操作数
  final int instantaneousOpsPerSec;

  /// 网络输入字节总数
  final int totalNetInputBytes;

  /// 网络输出字节总数
  final int totalNetOutputBytes;

  /// 每秒瞬时输入速率（KB）
  final double instantaneousInputKbps;

  /// 每秒瞬时输出速率（KB）
  final double instantaneousOutputKbps;

  /// 拒绝的连接总数
  final int rejectedConnections;

  /// 全量同步次数
  final int syncFull;

  /// 成功的部分同步次数
  final int syncPartialOk;

  /// 失败的部分同步次数
  final int syncPartialErr;

  /// 已过期键的数量
  final int expiredKeys;

  /// 已过期键过时百分比
  final double expiredStalePerc;

  /// 达到时间上限的过期键数量
  final int expiredTimeCapReachedCount;

  /// 被驱逐的键数量
  final int evictedKeys;

  /// 键空间命中次数
  final int keyspaceHits;

  /// 键空间丢失次数
  final int keyspaceMisses;

  /// 发布订阅频道数量
  final int pubsubChannels;

  /// 发布订阅模式数量
  final int pubsubPatterns;

  /// 最近一次 fork 操作的耗时（微秒）
  final int latestForkUsec;

  /// 缓存的迁移套接字数量
  final int migrateCachedSockets;

  /// 被跟踪的到期键数量
  final int slaveExpiresTrackedKeys;

  /// 主动内存重整命中次数
  final int activeDefragHits;

  /// 主动内存重整丢失次数
  final int activeDefragMisses;

  /// 主动内存重整键命中次数
  final int activeDefragKeyHits;

  /// 主动内存重整键丢失次数
  final int activeDefragKeyMisses;

  /// StatsInfo
  StatsInfo({
    required this.totalConnectionsReceived,
    required this.totalCommandsProcessed,
    required this.instantaneousOpsPerSec,
    required this.totalNetInputBytes,
    required this.totalNetOutputBytes,
    required this.instantaneousInputKbps,
    required this.instantaneousOutputKbps,
    required this.rejectedConnections,
    required this.syncFull,
    required this.syncPartialOk,
    required this.syncPartialErr,
    required this.expiredKeys,
    required this.expiredStalePerc,
    required this.expiredTimeCapReachedCount,
    required this.evictedKeys,
    required this.keyspaceHits,
    required this.keyspaceMisses,
    required this.pubsubChannels,
    required this.pubsubPatterns,
    required this.latestForkUsec,
    required this.migrateCachedSockets,
    required this.slaveExpiresTrackedKeys,
    required this.activeDefragHits,
    required this.activeDefragMisses,
    required this.activeDefragKeyHits,
    required this.activeDefragKeyMisses,
  });

  /// fromMap
  factory StatsInfo.fromMap(Map<String, String> map) {
    return StatsInfo(
      totalConnectionsReceived:
          int.parse(map['total_connections_received'] ?? '0'),
      totalCommandsProcessed: int.parse(map['total_commands_processed'] ?? '0'),
      instantaneousOpsPerSec:
          int.parse(map['instantaneous_ops_per_sec'] ?? '0'),
      totalNetInputBytes: int.parse(map['total_net_input_bytes'] ?? '0'),
      totalNetOutputBytes: int.parse(map['total_net_output_bytes'] ?? '0'),
      instantaneousInputKbps:
          double.parse(map['instantaneous_input_kbps'] ?? '0.0'),
      instantaneousOutputKbps:
          double.parse(map['instantaneous_output_kbps'] ?? '0.0'),
      rejectedConnections: int.parse(map['rejected_connections'] ?? '0'),
      syncFull: int.parse(map['sync_full'] ?? '0'),
      syncPartialOk: int.parse(map['sync_partial_ok'] ?? '0'),
      syncPartialErr: int.parse(map['sync_partial_err'] ?? '0'),
      expiredKeys: int.parse(map['expired_keys'] ?? '0'),
      expiredStalePerc: double.parse(map['expired_stale_perc'] ?? '0.0'),
      expiredTimeCapReachedCount:
          int.parse(map['expired_time_cap_reached_count'] ?? '0'),
      evictedKeys: int.parse(map['evicted_keys'] ?? '0'),
      keyspaceHits: int.parse(map['keyspace_hits'] ?? '0'),
      keyspaceMisses: int.parse(map['keyspace_misses'] ?? '0'),
      pubsubChannels: int.parse(map['pubsub_channels'] ?? '0'),
      pubsubPatterns: int.parse(map['pubsub_patterns'] ?? '0'),
      latestForkUsec: int.parse(map['latest_fork_usec'] ?? '0'),
      migrateCachedSockets: int.parse(map['migrate_cached_sockets'] ?? '0'),
      slaveExpiresTrackedKeys:
          int.parse(map['slave_expires_tracked_keys'] ?? '0'),
      activeDefragHits: int.parse(map['active_defrag_hits'] ?? '0'),
      activeDefragMisses: int.parse(map['active_defrag_misses'] ?? '0'),
      activeDefragKeyHits: int.parse(map['active_defrag_key_hits'] ?? '0'),
      activeDefragKeyMisses: int.parse(map['active_defrag_key_misses'] ?? '0'),
    );
  }
}

/// ReplicationInfo
class ReplicationInfo {
  /// 角色（master 或 slave）
  final String role;

  /// 已连接的从节点数量
  final int connectedSlaves;

  /// 从节点信息
  final List<SlaveInfo> slaves;

  /// 主节点复制 ID
  final String masterReplid;

  /// 主节点复制 ID（第二个）
  final String masterReplid2;

  /// 主节点复制偏移量
  final int masterReplOffset;

  /// 第二个复制偏移量
  final int secondReplOffset;

  /// 是否启用复制积压
  final int replBacklogActive;

  /// 复制积压大小
  final int replBacklogSize;

  /// 复制积压第一个字节偏移量
  final int replBacklogFirstByteOffset;

  /// 复制积压历史长度
  final int replBacklogHistlen;

  /// ReplicationInfo
  ReplicationInfo({
    required this.role,
    required this.connectedSlaves,
    required this.slaves,
    required this.masterReplid,
    required this.masterReplid2,
    required this.masterReplOffset,
    required this.secondReplOffset,
    required this.replBacklogActive,
    required this.replBacklogSize,
    required this.replBacklogFirstByteOffset,
    required this.replBacklogHistlen,
  });

  /// fromMap
  factory ReplicationInfo.fromMap(Map<String, String> map) {
    List<SlaveInfo> slaves = [];
    for (int i = 0; i < int.parse(map['connected_slaves'] ?? '0'); i++) {
      slaves.add(SlaveInfo.fromMap(map, i));
    }
    return ReplicationInfo(
      role: map['role'] ?? '',
      connectedSlaves: int.parse(map['connected_slaves'] ?? '0'),
      slaves: slaves,
      masterReplid: map['master_replid'] ?? '',
      masterReplid2: map['master_replid2'] ?? '',
      masterReplOffset: int.parse(map['master_repl_offset'] ?? '0'),
      secondReplOffset: int.parse(map['second_repl_offset'] ?? '0'),
      replBacklogActive: int.parse(map['repl_backlog_active'] ?? '0'),
      replBacklogSize: int.parse(map['repl_backlog_size'] ?? '0'),
      replBacklogFirstByteOffset:
          int.parse(map['repl_backlog_first_byte_offset'] ?? '0'),
      replBacklogHistlen: int.parse(map['repl_backlog_histlen'] ?? '0'),
    );
  }
}

/// SlaveInfo
class SlaveInfo {
  /// 从节点的IP地址
  final String ip;

  /// 从节点的端口
  final int port;

  /// 从节点的状态
  final String state;

  /// 从节点的复制偏移量
  final int offset;

  /// 从节点的复制延迟
  final int lag;

  /// SlaveInfo
  SlaveInfo({
    required this.ip,
    required this.port,
    required this.state,
    required this.offset,
    required this.lag,
  });

  /// fromMap
  factory SlaveInfo.fromMap(Map<String, String> map, int index) {
    return SlaveInfo(
      ip: map['slave${index}_ip'] ?? '',
      port: int.parse(map['slave${index}_port'] ?? '0'),
      state: map['slave${index}_state'] ?? '',
      offset: int.parse(map['slave${index}_offset'] ?? '0'),
      lag: int.parse(map['slave${index}_lag'] ?? '0'),
    );
  }
}

/// CPUInfo
class CPUInfo {
  /// 系统 CPU 使用时间
  final double usedCpuSys;

  /// 用户 CPU 使用时间
  final double usedCpuUser;

  /// 子进程的系统 CPU 使用时间
  final double usedCpuSysChildren;

  /// 子进程的用户 CPU 使用时间
  final double usedCpuUserChildren;

  /// CPUInfo
  CPUInfo({
    required this.usedCpuSys,
    required this.usedCpuUser,
    required this.usedCpuSysChildren,
    required this.usedCpuUserChildren,
  });

  /// fromMap
  factory CPUInfo.fromMap(Map<String, String> map) {
    return CPUInfo(
      usedCpuSys: double.parse(map['used_cpu_sys'] ?? '0'),
      usedCpuUser: double.parse(map['used_cpu_user'] ?? '0'),
      usedCpuSysChildren: double.parse(map['used_cpu_sys_children'] ?? '0'),
      usedCpuUserChildren: double.parse(map['used_cpu_user_children'] ?? '0'),
    );
  }
}

/// ClusterInfo
class ClusterInfo {
  /// 是否启用集群模式
  final bool clusterEnabled;

  /// ClusterInfo
  ClusterInfo({
    required this.clusterEnabled,
  });

  /// fromMap
  factory ClusterInfo.fromMap(Map<String, String> map) {
    return ClusterInfo(
      clusterEnabled: map['cluster_enabled'] == '1',
    );
  }
}

/// KeyspaceInfo
class KeyspaceInfo {
  /// 数据库信息
  final List<DBInfo> databases;

  /// KeyspaceInfo
  KeyspaceInfo({
    required this.databases,
  });

  /// fromMap
  factory KeyspaceInfo.fromMap(Map<String, String> map) {
    final dbMap = <int, DBInfo>{};

    var defaultDBInfo = DBInfo(keys: 0, expires: 0, avgTtl: 0); // 假设的默认DBInfo值

    // 初始化一个变量来存储最大索引值
    int maxIndex = 0;

    // 首先遍历map以确定最大索引
    map.forEach((key, value) {
      if (key.startsWith('db')) {
        final index = int.parse(key.substring(2)); // 从 "db" 后提取索引
        maxIndex = index > maxIndex ? index : maxIndex; // 更新maxIndex为最大值
        dbMap[index] = DBInfo.fromString(value); // 此时暂时存儲到dbMap中
      }
    });

    // 创建列表并使用默认DBInfo对象初始化
    final List<DBInfo> databases =
        List.generate(maxIndex + 1, (index) => defaultDBInfo);

    // 填充真实的DBInfo对象到相应的索引位置
    dbMap.forEach((index, dbInfo) {
      databases[index] = dbInfo;
    });

    return KeyspaceInfo(databases: databases);
  }

  @override
  String toString() {
    // 使用map方法将每个DBInfo对象转换为字符串，然后使用join方法将它们连接起来
    return 'KeyspaceInfo{databases: ${databases.map((db) => db.toString()).join(', ')}}';
  }
}

/// DBInfo
class DBInfo {
  /// 键的数量
  final int keys;

  /// 设置了过期时间的键的数量
  final int expires;

  /// 平均 TTL（毫秒）
  final int avgTtl;

  /// DBInfo
  DBInfo({
    required this.keys,
    required this.expires,
    required this.avgTtl,
  });

  /// fromString
  factory DBInfo.fromString(String str) {
    final parts = str.split(',');
    final info = <String, int>{};
    for (var part in parts) {
      final kv = part.split('=');
      info[kv[0]] = int.parse(kv[1]);
    }
    return DBInfo(
      keys: info['keys'] ?? 0,
      expires: info['expires'] ?? 0,
      avgTtl: info['avg_ttl'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'DBInfo{keys: $keys, expires: $expires, avgTtl: $avgTtl}';
  }
}
