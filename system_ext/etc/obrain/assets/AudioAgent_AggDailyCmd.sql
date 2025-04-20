-- val_start_ts,      --obrain_start_ts
-- val_end_ts,        --obrain_end_ts
-- val_wall_start_ts  --wall_start_ts_round

insert into agg_audio_app_daily
SELECT {val_start_ts} as 'start_ts', {val_end_ts} as 'end_ts', {val_wall_start_ts} as 'timestamp',
      name, sum(foreground_duration) as 'foreground_duration', sum(foreground_energy) as 'foreground_energy',
      sum(background_duration) as 'background_duration', sum(background_energy) as 'background_energy',
      sum(screen_on_duration) as 'screen_on_duration', sum(screen_on_energy) as 'screen_on_energy',
      sum(screen_off_duration) as 'screen_off_duration', sum(screen_off_energy) as 'screen_off_energy'
from agg_audio_app_hourly
where start_ts >= {val_start_ts} and end_ts <= {val_end_ts}
group by name;

insert into agg_audio_device_daily
SELECT {val_start_ts} as 'start_ts', {val_end_ts} as 'end_ts', {val_wall_start_ts} as 'timestamp',
      sum(foreground_duration) as 'foreground_duration', sum(foreground_energy) as 'foreground_energy',
      sum(background_duration) as 'background_duration', sum(background_energy) as 'background_energy',
      sum(screen_on_duration) as 'screen_on_duration', sum(screen_on_energy) as 'screen_on_energy',
      sum(screen_off_duration) as 'screen_off_duration', sum(screen_off_energy) as 'screen_off_energy'
from agg_audio_app_hourly
where start_ts >= {val_start_ts} and end_ts <= {val_end_ts};

insert into agg_audio_volume_app_daily
SELECT {val_start_ts} as 'start_ts', {val_end_ts} as 'end_ts', {val_wall_start_ts} as 'timestamp',
      screen_mode,
      charger_mode,
      name,
      device,
      volume,
      sum(total_du) as 'total_du'
from agg_audio_volume_app_hourly
where start_ts >= {val_start_ts} and end_ts <= {val_end_ts}
group by screen_mode, charger_mode, name, device, volume
order by total_du desc limit 100;

--by_app  upload dcs-------------------------------------------------------------------------
select upload_dcs('{upload_dcs_key}', '{log_tag_app}', '{config_id_app}', {version}, '{type}', {agent_type},
                  '{id}', '{start_wall_time}', '{end_wall_time}', '{meta_data}', by_app)
from (
    select json_insert(json_set('{{}}', '$.column_key', json(column_key)), '$.row_value', json(row_value)) as 'by_app'
    from (
        select
            json_set('{{}}', '$', json_array('timestamp', 'name', 'foreground_duration',
                'foreground_energy', 'background_duration', 'background_energy', 'screen_on_duration',
                'screen_on_energy', 'screen_off_duration', 'screen_off_energy')) as column_key,
            json_set('{{}}', '$', json_group_array(json_array(timestamp, obfuscate(name),
                foreground_duration,foreground_energy,background_duration, background_energy,
                screen_on_duration,screen_on_energy, screen_off_duration, screen_off_energy)))  as row_value
        from agg_audio_app_daily
        where start_ts >= {val_start_ts} and end_ts <= {val_end_ts}
    )
);

select upload_dcs('{upload_dcs_key}', '{log_tag_volume_app}', '{config_id_volume_app}', {version}, '{type}', {agent_type},
                  '{id}', '{start_wall_time}', '{end_wall_time}', '{meta_data}', by_app)
from (
    select json_insert(json_set('{{}}', '$.column_key', json(column_key)), '$.row_value', json(row_value)) as 'by_app'
    from (
        select
            json_set('{{}}', '$', json_array('timestamp', 'screen_mode',
                'charger_mode', 'name', 'device', 'volume', 'total_du')) as column_key,
            json_set('{{}}', '$', json_group_array(json_array(timestamp,
                screen_mode, charger_mode, obfuscate(name), device, volume, total_du)))  as row_value
        from agg_audio_volume_app_daily
        where start_ts >= {val_start_ts} and end_ts <= {val_end_ts}
    )
);


--by_device  upload dcs-------------------------------------------------------------------------
select upload_dcs('{upload_dcs_key}', '{log_tag_device}', '{config_id_device}', {version}, '{type}', {agent_type},
                  '{id}', '{start_wall_time}', '{end_wall_time}', '{meta_data}', by_device)
from (
    select json_insert(json_set('{{}}', '$.column_key', json(column_key)), '$.row_value', json(row_value)) as 'by_device'
    from (
        select
            json_set('{{}}', '$', json_array('timestamp', 'foreground_duration',
                'foreground_energy', 'background_duration', 'background_energy', 'screen_on_duration',
                'screen_on_energy', 'screen_off_duration', 'screen_off_energy')) as column_key,
            json_set('{{}}', '$', json_group_array(json_array(timestamp,
                foreground_duration,foreground_energy,background_duration, background_energy,
                screen_on_duration,screen_on_energy, screen_off_duration, screen_off_energy)))  as row_value
        from (
            select timestamp,
                sum(foreground_duration) as foreground_duration,sum(foreground_energy) as foreground_energy,
                sum(background_duration) as background_duration, sum(background_energy) as background_energy,
                sum(screen_on_duration) as screen_on_duration,sum(screen_on_energy) as screen_on_energy,
                sum(screen_off_duration) as screen_off_duration, sum(screen_off_energy) as screen_off_energy
            from agg_audio_app_daily
            where start_ts >= {val_start_ts} and end_ts <= {val_end_ts}
        )
    )
);

--by_app
--|start_ts     |end_ts       |timesptamp---|-------------name---------------|foreground_duration| foreground_energy |background_duration|background_energy|screen_on_duration|screen_on_energy|screen_off_duration|screen_off_energy
--|1676359917975|1676359958037|1676358000000|com.smile.gifmaker@11.0.11.29263|24067	             |630372	         |1477               |33888	           |25430	          |661645	       |114                |   	2615    |
--|1676359917975|1676359958037|1676358000000|com.ss.android.ugc.aweme@24.1.0 |27214	             |648866	         |0	                 |0                |27214	          |648866	       |0	               |       0    |

--by_device
--|start_ts     |end_ts       |timesptamp---|foreground_duration| foreground_energy |background_duration|background_energy|screen_on_duration|screen_on_energy|screen_off_duration|screen_off_energy
--|1676359917975|1676359958037|1676358000000|24067	             |630372	         |1477               |33888	           |25430	          |661645	       |114                |   	2615    |
