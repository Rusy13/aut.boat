import 'System'
import 'UnityEngine'
import 'Assembly-CSharp'
import 'Math'

function sign(x)
	if x<0 then
     return -1
   elseif x>0 then
     return 1
   else
     return 0
   end
end

prevInput = 0
integral = 0.0

--Вызывается каждый шаг. Возвращаемое значение перезаписывается в симуляторе и отправляется в функцию физики
function Step(boatLocation, targetLocation, boat)
	local radianPoint1_longitude
	local radianPoint1_latitude
	local radianPoint2_longitude
	local radianPoint2_latitude
	local cl1, cl2, sl1, sl2
	local deltaLon, cDeltaLon, sDeltaLon
	local y, x, distance, z, z2
	local newCourse, anglerad2

	Debug.Log("luaStep");
	-- Opens a file in append mode
	file = io.open("autopilot_output_debug.txt", "a")

	-- Перевод в радианы
	radianPoint1_longitude = boatLocation.y*math.pi/180
	radianPoint1_latitude  = boatLocation.x*math.pi/180
	radianPoint2_longitude = targetLocation.y*math.pi/180
	radianPoint2_latitude  = targetLocation.x*math.pi/180

	-- Find cosinuses and sinuses
	cl1 = math.cos(radianPoint1_latitude)
	cl2 = math.cos(radianPoint2_latitude)
	sl1 = math.sin(radianPoint1_latitude)
	sl2 = math.sin(radianPoint2_latitude)
	deltaLon = radianPoint2_longitude - radianPoint1_longitude
	cDeltaLon = math.cos(deltaLon)
	sDeltaLon = math.sin(deltaLon)

	-- Large circle length calculation
	y = math.sqrt(math.pow(cl2*sDeltaLon, 2) + math.pow(cl1*sl2-sl1*cl2*cDeltaLon, 2))
	x = sl1*sl2+cl1*cl2*cDeltaLon
	-- Distance at meters
	distance = math.atan2(y, x)*6372795

	-- Calculation of the initial azimuth
	x = (cl1*sl2) - (sl1*cl2*cDeltaLon)
	y = sDeltaLon*cl2
	z = (math.atan((-1)*y/x))*180/math.pi
	if x < 0 then z = z + 180 end
	z2 = z + 180
	z2 = math.fmod(z2,360) - 180

	file:write("z2 = ")
	file:write(z2)

	z2 = (-1)*z2*math.pi/180
	anglerad2 = z2 - (2*math.pi*math.floor((z2/(2*math.pi))))
	-- newCourse = anglerad2*180/math.pi
	newCourse = anglerad2
	-- appends a word test to the last line of the file
	file:write("\tBoatXi = ")
	file:write(boat.Xi)
	file:write("\tnewCourse = ")
	file:write(newCourse)
	file:write("\n")
	-- closes the open file
	file:close()
	

	-- global prevInput
	-- global integral
	local error1 = 0.0
	local output = 0.0
	--const-----------
	local lim = 0.78
	local Kp = 0.800
	local Ki = 0.360
	local Kd = 0.440
	local _dt_s = 0.01
	------------------

	error1 = newCourse - boat.Xi

	if error1 > 180 then error1 = -(360 - error1) end
	if error1 < -180 then error1 = 360 + error1 end

	delta_input = prevInput  - boat.Xi 
	prevInput = boat.Xi
	output = error1 * Kp                         -- пропорционально ошибке регулирования
	output = output + delta_input * Kd / _dt_s   -- дифференциальная составляющая
	integral = integral + error1 * Ki * _dt_s    -- расчёт интегральной составляющей -- тут можно ограничить интегральную составляющую!
	output = output + integral                   -- прибавляем интегральную составляющую

	if output < -lim then output = -lim end
	if output > lim then output = lim end

 	--output = constrain(output, pidMin, pidMax) -- ограничиваем выход

	boat.alpha = output

	-- устанавоиваем выходные значения в радианах
	--boat.Xi = newCourse

	--boat.alpha = erorr1
	--if math.abs(boat.alpha) > math.rad(45) then 
	--	boat.alpha = sign(boat.alpha) * math.rad(45)
	--end

  	--boat.alpha = computePID()
	--boat.alpha = newCourse - boat.Xi

	boat.kr = 1

	return boat
end