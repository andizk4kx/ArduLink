-- eumodbus.e a wrapper for libmodbus see: https://libmodbus.org/
-- 
-- 
-- 
-- 
-- 
--  <2017> <Andreas Wagner andi@indonesianet.de>



namespace modbus

--without define DEBUG

--include std\dll.e
--include std\machine.e
--include std\convert.e



public enum A=1,B,C,D
public constant MAX_PDU=256
integer ScanAddr=4096
constant Modbus_Port=502
sequence modbusdll

if machine_bits()=32 then
        modbusdll="libmodbus-5-32.dll"
    else
        modbusdll="libmodbus-5-64.dll"      
end if

atom modbus = open_dll(modbusdll,False)
if not(modbus) then
    puts(1,"failed to load "&modbusdll&"\n")
Void=   getc(0)
    --abort(0)
end if

procedure not_found(sequence name)
    puts (1, "Couldn't find " & name)
    puts (1, " Maybe this could lead to some trouble...\n")
--    sleep (5)
--  abort(1)
end procedure

function link_c_func(atom dll, sequence name, sequence args, atom result)
-- dynamically link a C routine as a Euphoria function
integer handlea

    handlea = define_c_func (dll, name, args, result)
    if handlea=-1 then
        not_found(name)
        return -1
    else
        return handlea
    end if
end function

function link_c_proc(atom dll, sequence name, sequence args)
-- dynamically link a C routine as a Euphoria function
integer handlea

    handlea = define_c_proc(dll, name, args)
    if handlea=-1 then
        not_found(name)
        return -1
    else
        return handlea
    end if
end function

-- defined in modbus.h
--typedef struct _modbus modbus_t;
--
--typedef struct {
--    int nb_bits;                  --on Win32 32bits
--    int nb_input_bits;            --on Win32 32bits
--    int nb_input_registers;       --on Win32 32bits
--    int nb_registers;             --on Win32 32bits
--    uint8_t *tab_bits;            --on Win32 32bits pointer to 8bit tab
--    uint8_t *tab_input_bits;      --on Win32 32bits pointer to 8bit tab
--    uint16_t *tab_input_registers;--on Win32 32bits pointer to 16bit tab
--    uint16_t *tab_registers;      --on Win32 32bits pointer to 16bit tab
--} modbus_mapping_t;

-- constant SIZE_OF_MODBUS_CONTEXT=4+4+4+4+4+4+4+4


atom modbus_new_tcp=link_c_func(modbus,"modbus_new_tcp",{C_POINTER,C_INT},C_INT)
atom modbus_free=link_c_proc(modbus,"modbus_free",{C_POINTER})
atom modbus_close=link_c_proc(modbus,"modbus_close",{C_POINTER})
atom modbus_connect=link_c_func(modbus,"modbus_connect",{C_POINTER},C_INT)
atom modbus_flush=link_c_func(modbus,"modbus_flush",{C_POINTER},C_INT)
atom modbus_send_raw_request=link_c_func(modbus,"modbus_send_raw_request",{C_POINTER,C_POINTER,C_INT},C_INT)
atom modbus_receive_confirmation=link_c_func(modbus,"modbus_receive_confirmation",{C_POINTER,C_POINTER},C_INT)
atom modbus_report_slave_id=link_c_func(modbus,"modbus_report_slave_id",{C_POINTER,C_POINTER},C_INT)
atom modbus_write_register=link_c_func(modbus,"modbus_write_register",{C_POINTER,C_INT,C_INT},C_INT)
atom modbus_read_registers=link_c_func(modbus,"modbus_read_registers",{C_POINTER,C_INT,C_INT,C_POINTER},C_INT)
atom modbus_write_registers=link_c_func(modbus,"modbus_write_registers",{C_POINTER,C_INT,C_INT,C_POINTER},C_INT)

atom modbus_new_rtu=link_c_func(modbus,"modbus_new_rtu",{C_POINTER,C_INT,C_INT,C_INT,C_INT},C_POINTER)
atom modbus_set_slave=link_c_func(modbus,"modbus_set_slave",{C_POINTER,C_INT},C_INT)

atom modbus_get_float_abcd=link_c_func(modbus,"modbus_get_float_abcd",{C_POINTER},C_FLOAT)
atom modbus_get_float_badc=link_c_func(modbus,"modbus_get_float_badc",{C_POINTER},C_FLOAT)
atom modbus_get_float_cdab=link_c_func(modbus,"modbus_get_float_cdab",{C_POINTER},C_FLOAT)
atom modbus_get_float_dcba=link_c_func(modbus,"modbus_get_float_dcba",{C_POINTER},C_FLOAT)

atom modbus_get_response_timeout=link_c_func(modbus,"modbus_get_response_timeout",{C_POINTER,C_POINTER,C_POINTER},C_INT)
atom modbus_set_response_timeout=link_c_func(modbus,"modbus_set_response_timeout",{C_POINTER,C_UINT,C_UINT},C_INT)
atom modbus_get_byte_timeout=link_c_func(modbus,"modbus_get_byte_timeout",{C_POINTER,C_POINTER,C_POINTER},C_INT)
atom modbus_set_byte_timeout=link_c_func(modbus,"modbus_set_byte_timeout",{C_POINTER,C_UINT,C_UINT},C_INT)

atom modbus_set_debug=link_c_func(modbus,"modbus_set_debug",{C_POINTER,C_INT},C_INT)

atom modbus_receive=link_c_func(modbus,"modbus_receive",{C_POINTER,C_POINTER},C_INT)
atom modbus_reply=link_c_func(modbus,"modbus_reply",{C_POINTER,C_POINTER,C_UINT,C_POINTER},C_INT)
atom modbus_mapping_new=link_c_func(modbus,"modbus_mapping_new",{C_UINT,C_UINT,C_UINT,C_UINT},C_POINTER)


public function Receive(atom ctx,atom buffer)
    return c_func(modbus_receive,{ctx,buffer})
end function

public function New_Tcp(object ip,integer port=Modbus_Port)
atom Ip=allocate_string(ip)
atom    modbusctx=c_func(modbus_new_tcp,{Ip,port})
free(Ip)
return modbusctx
end function

public function New_Rtu(object comport,atom baud=9600, atom parity='N', atom data_bits=8, atom stop_bits=1)
atom pzcomport=allocate_string(comport)
atom result=c_func(modbus_new_rtu,{pzcomport,baud,parity,data_bits,stop_bits})  
free(pzcomport)
return result
end function

public function Set_Slave(atom ctx, atom id)
    return c_func(modbus_set_slave,{ctx,id})    
end function

public function Connect(atom ctx)
    return c_func(modbus_connect,{ctx})
end function

public procedure Close(atom ctx)
    c_proc(modbus_close,{ctx})
end procedure

public procedure Free(atom ctx)
    c_proc(modbus_free,{ctx})
end procedure

public function Flush(atom ctx)
return c_func(modbus_flush,{ctx})
end function

public function Report_Slave_Id(atom ctx,atom buffer)
    return c_func(modbus_report_slave_id,{ctx,buffer})
end function

public function Raw_Send(atom ctx,sequence request)
atom req=allocate(length(request)+1)
for i = 0 to length(request)-1 do
    poke(req+i,request[i+1])
end for
atom result=c_func(modbus_send_raw_request,{ctx,req,length(request)})
free(req)
return result
end function

public function Raw_Receive(atom ctx)
object result=0
atom rsp=allocate(MAX_PDU)
    result=c_func(modbus_receive_confirmation,{ctx,rsp})
    if result>1 then
        result=repeat(0,result)
        for i = 0 to length(result)-1 do
            result[i+1]=peek(rsp+i) 
        end for
        free(rsp)
        return result
    else
        free(rsp)
        return result
    end if
end function

public function Write_Register(atom ctx,atom addr,atom value)
atom result
    result=c_func(modbus_write_register,{ctx,addr,value})
return result    
end function

public function Write_Registers(atom ctx,atom addr,sequence value,atom reg_count=1)
atom result
atom buffer=allocate(2*reg_count)
    poke2(buffer,value)
    result=c_func(modbus_write_registers,{ctx,addr,reg_count,buffer})
    free(buffer)
return result    
end function

--
-- Reading Modbus Register, a modbus register is 16bit
--

public function Read_Register32u(atom ctx,atom addr)
atom buffer=allocate(4)
object result=-1
result = c_func(modbus_read_registers,{ctx,addr,2,buffer})
if result>0 then
    result=peek4u(buffer) 
   else
    result="Error"
end if
free(buffer)
return result
end function

public function Read_Register16u(atom ctx,atom addr)
atom buffer=allocate(2)
object result=-1
result = c_func(modbus_read_registers,{ctx,addr,1,buffer})
if result>0 then
    result=peek2u(buffer) 
   else
    result="Error"
end if
free(buffer)
return result
end function

public function Read_Registers16u(atom ctx, atom addr,atom reg_count=1)
atom buffer=allocate(reg_count*2)
object result
atom erg=-1

erg = c_func(modbus_read_registers,{ctx,addr,reg_count,buffer})
if erg>0 then
    result=peek2u({buffer,erg}) 
   else
    result="Error"
end if
free(buffer)

return result
end function

public function Read_Register32s(atom ctx,atom addr)
atom buffer=allocate(4)
object result=-1
result = c_func(modbus_read_registers,{ctx,addr,2,buffer})
if result>0 then
    result=peek4s(buffer) 
   else
    result="Error"
end if
free(buffer)
return result
end function

public function Read_Register16s(atom ctx,atom addr)
atom buffer=allocate(2)
object result=-1
result = c_func(modbus_read_registers,{ctx,addr,1,buffer})
if result>0 then
    result=peek2s(buffer) 
   else
    result="Error"
end if
free(buffer)
return result
end function

public function Read_Registers16s(atom ctx, atom addr,atom reg_count=1)
atom buffer=allocate(reg_count*2)
object result=-1
result = c_func(modbus_read_registers,{ctx,addr,reg_count,buffer})
if result>0 then
    result=peek2s({buffer,reg_count}) 
   else
    result="Error"
end if
free(buffer)
return result
end function

public function Read_Register_Float(atom ctx,atom addr,integer mode=A)
atom buffer=allocate(4)
object result=-1
result = c_func(modbus_read_registers,{ctx,addr,2,buffer})
if result>0 then
    switch mode do
            case A then result=c_func(modbus_get_float_abcd,{buffer}) break
            case B then result=c_func(modbus_get_float_badc,{buffer}) break
            case C then result=c_func(modbus_get_float_cdab,{buffer}) break
            case D then result=c_func(modbus_get_float_dcba,{buffer}) 
    end switch
    -- result=peek4u(buffer) 
   else
    result="Error"
end if
free(buffer)
return result
end function


--
-- Setting/getting timeouts 
--

public function Set_Timeout(atom ctx,integer sec=1,integer msec=0)
atom result
    msec=msec*1000
    result=c_func(modbus_set_response_timeout,{ctx,sec,msec})
return result
end function

public function Get_Timeout(atom ctx)
atom psec=allocate(4)
atom pmmsec=allocate(4)
object result
    result=c_func(modbus_get_response_timeout,{ctx,psec,pmmsec})
    if result>(-1) then
        result={peek4u(psec),peek4u(pmmsec)}
    else
        -- do nothing
    end if
free(psec)
free(pmmsec)
return result    
end function

public function Set_Byte_Timeout(atom ctx,integer sec=1,integer msec=0)
atom result
    msec=msec*1000
    result=c_func(modbus_set_byte_timeout,{ctx,sec,msec})
return result
end function

public function Get_Byte_Timeout(atom ctx)
atom psec=allocate(4)
atom pmmsec=allocate(4)
object result
    result=c_func(modbus_get_byte_timeout,{ctx,psec,pmmsec})
    if result>(-1) then
        result={peek4u(psec),peek4u(pmmsec)}
    else
        -- do nothing
    end if
free(psec)
free(pmmsec)
return result    
end function



-- Zusaetzliche Helferfunktionen

sequence com_ports={"COM1:","COM2:","COM3:","COM4:",
                    "COM5:","COM6:","COM7:","COM8:","COM9:"}

public function Scan_Com_Ports()
atom ctx=0
sequence result=""
for i = 1 to length(com_ports) do
    ctx=New_Rtu(com_ports[i])
    if Connect(ctx)<0 then
--  ifdef DEBUG then 
        puts(1,"No Port on  "&com_ports[i]&"\n")
--  end ifdef
    else
--  ifdef DEBUG then
        puts(1,"Port active on  "&com_ports[i]&"\n")
--  end ifdef
    result=append(result,com_ports[i])
    end if
    Close(ctx)
    Free(ctx)
end for   
return result
end function

public function Scan_Rtu_Station(integer start=1,integer ende=32,sequence comport="COM1:",atom baud=9600, atom parity='N', atom data_bits=8, atom stop_bits=1)
atom ctx=0
sequence result=""
    ctx=New_Rtu(comport,baud,parity,data_bits,stop_bits)
    for i = start to ende do
            Void=Set_Slave(ctx,i)
            Void=Connect(ctx)
            if atom(Read_Register32u(ctx,ScanAddr)) then
                    result=append(result,i)
--          ifdef DEBUG then
--              puts(1,"Station active on "&comport&sprintf("%4d",i)&"\n")
--          end ifdef
            end if
            Void=Flush(ctx)
            Close(ctx)
    end for
    Free(ctx)
return result
end function


public function Set_Debug(atom ctx,integer flag=0)
    return c_func(modbus_set_debug,{ctx,flag})
end function
--
-- Byteorder helper
--

public function swap32(atom int32)
object bytes
object lo,hi,result
    bytes=int_to_bytes(int32)
    hi=bytes[1..2]
    lo=bytes[3..4]
    result=lo&hi
    return bytes_to_int(result)
end function

public function swap16(atom int16)
object bytes
object lo,hi,result
    bytes=int_to_bytes(int16)
    hi=bytes[1]
    lo=bytes[2]
    result=lo&hi
    return bytes_to_int(result)
end function

public function lobyte(atom int16)
        return and_bits(#00FF,int16)
end function

public function hibyte(atom int16)
        return floor(and_bits(#FF00,int16)/#100)
end function


public function loword(atom dword)
        return and_bits(#0000FFFF,dword)
end function

public function hiword(atom dword)
        return floor(and_bits(#FFFF0000,dword)/#10000)
end function


