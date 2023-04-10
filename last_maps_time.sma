#include <amxmodx>
#include <amxmisc>
#include <unixtime>
#include <cromchat>

// number of last maps to save
#define LAST_MAPS_SAVE 15

new gSaveFile[64];
//new gSaveFile[] = addons/amxmodx/logs/lastmaps;
new gLastMapName[LAST_MAPS_SAVE][32];
new gLastMapTime[LAST_MAPS_SAVE];
new gNumLastMaps;

new g_Date[64];


public plugin_init() {
	register_plugin("Last Maps Time", "0.0.1", "Exolent");
	
	register_clcmd("say /lastmaps", "CmdLastMaps", ADMIN_KICK, "Print Last Maps");

	new iTime; //iTimeAdjusted ,
	new iYear , iMonth , iDay , iHour , iMinute , iSecond;
	iTime = get_systime();
	UnixToTime( iTime , iYear , iMonth , iDay , iHour , iMinute , iSecond );

	//get_datadir(gSaveFile, charsmax(gSaveFile));
	get_localinfo("amxx_logs", gSaveFile, 63); //amxx logs
	formatex(g_Date, charsmax(g_Date),"/lastmaps/L%d%02d%02d.log", iYear, iMonth, iDay);
	add(gSaveFile, charsmax(gSaveFile), g_Date);
	new f = fopen(gSaveFile, "rt");
	
	if(f) {
		new line[64], minutes[12];
		
		while(!feof(f) && gNumLastMaps < LAST_MAPS_SAVE) {
			fgets(f, line, charsmax(line));
			trim(line);
			
			if(line[0]) {
				parse(line, gLastMapName[gNumLastMaps], charsmax(gLastMapName[]), minutes, charsmax(minutes));
				gLastMapTime[gNumLastMaps++] = str_to_num(minutes);
			}
		}
		
		fclose(f);
	}

	CC_SetPrefix("&x04[SCG]");
}

public plugin_end() {
	new minutes = floatround(get_gametime() / 60.0, floatround_ceil);
	
	new map[32];
	get_mapname(map, charsmax(map));
	
	new f = fopen(gSaveFile, "wt");
	
	fprintf(f, "^"%s^" %d", map, minutes);
	
	if(gNumLastMaps == LAST_MAPS_SAVE) {
		gNumLastMaps--;
	}
	
	for(new i = 0; i < gNumLastMaps; i++) {
		fprintf(f, "^n^"%s^" %d", gLastMapName[i], gLastMapTime[i]);
	}
	
	fclose(f);
}

public CmdLastMaps(id, lvl, cid) {
	if(!cmd_access(id, lvl, cid, 0))
		return PLUGIN_HANDLED;

	if(gNumLastMaps) {
		new maps[192], len;
		for(new i = 0; i < gNumLastMaps; i++) {
			//len += formatex(maps[len], charsmax(maps) - len, "%s%s (%dmin)", len ? ", " : "", gLastMapName[i], gLastMapTime[i]);
			len += formatex(maps[len], charsmax(maps) - len, "%s%s", len ? ", " : "", gLastMapName[i]);
		}
		
		CromChat(id, "^4Last Maps:^3 %s", maps);
	} else {
		CromChat(id, "^3 Sorry, no last maps have been saved in the logs.");
	}
	return PLUGIN_HANDLED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
