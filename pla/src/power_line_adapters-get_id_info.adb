------------------------------------------------------------------------
--  pla-util - A powerline adapter utility
--  Copyright (C) 2016-2022 John Serock
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program. If not, see <http://www.gnu.org/licenses/>.
------------------------------------------------------------------------
with Ada.Exceptions;
with Messages.Constructors;
with Packet_Sockets.Thin;

separate (Power_Line_Adapters)

function Get_Id_Info (Self                : Adapter_Type;
                      Network_Device_Name : String) return Id_Info_Type is

   use type Octets.Octets_Type;

   Confirmation          : Packets.Payload_Type (1 .. 266);
   Confirmation_Length   : Natural;
   Expected_Confirmation : constant Packets.Payload_Type := (16#01#, 16#61#, 16#60#, 16#00#, 16#00#);
   Id_Info               : Id_Info_Type;
   MAC_Address           : MAC_Addresses.MAC_Address_Type;
   Socket                : Packet_Sockets.Thin.Socket_Type;

begin

   begin

      Socket.Open (Protocol        => Packet_Sockets.Thin.Protocol_HomePlug,
                   Device_Name     => Network_Device_Name,
                   Receive_Timeout => Default_Receive_Timeout,
                   Send_Timeout    => Default_Send_Timeout);

      declare

         Request : constant Messages.Message_Type := Messages.Constructors.Create_Get_Id_Info_Request;

      begin

         Self.Process (Request             => Request,
                       Socket              => Socket,
                       Confirmation        => Confirmation,
                       Confirmation_Length => Confirmation_Length,
                       From_MAC_Address    => MAC_Address);

      end;

      if Confirmation_Length < 11 or else Confirmation (Expected_Confirmation'Range) /= Expected_Confirmation then
         raise Adapter_Error with Message_Unexpected_Confirmation;
      end if;

   exception

      when others =>
         Socket.Close;
         raise;

   end;

   Socket.Close;

   case Confirmation (10) is
      when 16#00# => Id_Info.Homeplug_AV_Version := HPAV_1_1;
      when 16#01# => Id_Info.Homeplug_AV_Version := HPAV_2_0;
      when 16#ff# => Id_Info.Homeplug_AV_Version := Not_HPAV;
      when others =>
         raise Adapter_Error with Message_Unexpected_Confirmation;
   end case;

   if Id_Info.Homeplug_AV_Version = HPAV_2_0 then

      Id_Info.MCS := MCS_Type'Val (Confirmation (12));

   else

      Id_Info.MCS := MIMO_Not_Supported;

   end if;

   return Id_Info;

exception

   when Error : Packets.Packet_Error | Packet_Sockets.Thin.Packet_Error =>
      raise Adapter_Error with Ada.Exceptions.Exception_Message (Error);

end Get_Id_Info;
