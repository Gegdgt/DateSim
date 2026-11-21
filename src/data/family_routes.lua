-- Entradas personales que dejan de existir tras una separación permanente.
local routes={
 day5_eris_training_invitation={wife="eris",to="day5_sylphiette"},
 day5_eris_duel={wife="eris",to="day5_sylphiette"},
 day5_training_reflection={wife="eris",to="day5_sylphiette"},
 day6_eris_rematch_offer={wife="eris",to="day6_companion"},
 day6_eris_rematch={wife="eris",to="day6_companion"},
 day6_eris_rematch_close={wife="eris",to="day6_companion"},
}
local wives={"sylphiette","roxy","eris"}
for i,id in ipairs(wives) do
 for _,prefix in ipairs({"day5_","day5_mission_","day5_battle_","day5_resolution_","day5_gift_","day5_after_"}) do
  routes[prefix..id]={wife=id,to=wives[i+1] and "day5_"..wives[i+1] or "day5_agenda",complete=not wives[i+1]}
 end
 routes["day7_"..id]={wife=id,to=wives[i+1] and "day7_"..wives[i+1] or "day7_council"}
 routes["day7_plan_"..id]={wife=id,to=wives[i+1] and "day7_plan_"..wives[i+1] or "day7_departures"}
end
return routes
