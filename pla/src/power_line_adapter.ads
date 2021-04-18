------------------------------------------------------------------------
--  pla-util - A powerline adapter utility
--  Copyright (C) 2016-2021 John Serock
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
with Ada.Containers.Bounded_Ordered_Sets;
--with Ethernet;
with Packet_Sockets.Thin;
with HFID_String;
with Interfaces;
with Packet_Sockets.Thin;

package Power_Line_Adapter is

   subtype NID_Type is Packet_Sockets.Thin.Bytes_Type(1 .. 7);

   type Adapter_Type is tagged private;

   type Network_Kind_Type is (IN_HOME_NETWORK, ACCESS_NETWORK);

   type Station_Role_Type is (UNASSOC_STA, UNASSOC_CCO, STA, CCO, BACKUP_CCO);

   type Status_Type is (JOINED, NOT_JOINED_HAVE_NMK, NOT_JOINED_NO_NMK);

   type Network_Info_Type is
      record
         NID                : NID_Type;
         SNID               : Interfaces.Unsigned_8;
         TEI                : Interfaces.Unsigned_8;
         CCo_MAC_Address    : Packet_Sockets.Thin.MAC_Address_Type;
         BCCo_MAC_Address   : Packet_Sockets.Thin.MAC_Address_Type;
         Num_Coord_Networks : Interfaces.Unsigned_8;
         Station_Role       : Station_Role_Type;
         Network_Kind       : Network_Kind_Type;
         Status             : Status_Type;
      end record;

   type Network_Info_List_Type is array (Positive range <>) of Network_Info_Type;

   Max_Adapters : constant := 16;

   Input_Error : exception;

   function "<"(Left  : in Adapter_Type;
                Right : in Adapter_Type) return Boolean;

   function "="(Left  : in Adapter_Type;
                Right : in Adapter_Type) return Boolean;

   function Check_DAK(Adapter     : in Adapter_Type;
                      Pass_Phrase : in String;
                      Socket      : in Packet_Sockets.Thin.Socket_Type) return Boolean;

   function Check_NMK(Adapter     : in Adapter_Type;
                      Pass_Phrase : in String;
                      Socket      : in Packet_Sockets.Thin.Socket_Type) return Boolean;

   function Get_MAC_Address(Adapter : in Adapter_Type) return Packet_Sockets.Thin.MAC_Address_Type;

   function Has_MAC_Address(Adapter     : in Adapter_Type;
                            MAC_Address : in String) return Boolean;

   function Get_Manufacturer_HFID(Adapter: in Adapter_Type;
                                  Socket : in Packet_Sockets.Thin.Socket_Type) return HFID_String.Bounded_String;

   function Get_User_HFID(Adapter : in Adapter_Type;
                          Socket  : in Packet_Sockets.Thin.Socket_Type) return HFID_String.Bounded_String;

   function Get_Any_Network_Info(Adapter : in Adapter_Type;
                                 Socket  : in Packet_Sockets.Thin.Socket_Type) return Network_Info_List_Type;

   function Get_Member_Network_Info(Adapter : in Adapter_Type;
                                    Socket  : in Packet_Sockets.Thin.Socket_Type) return Network_Info_List_Type;

   procedure Reset(Adapter : in Adapter_Type;
                   Socket  : in Packet_Sockets.Thin.Socket_Type);

   procedure Restart(Adapter : in Adapter_Type;
                     Socket  : in Packet_Sockets.Thin.Socket_Type);

   procedure Set_HFID(Adapter : in Adapter_Type;
                      HFID    : in HFID_String.Bounded_String;
                      Socket  : in Packet_Sockets.Thin.Socket_Type);

   procedure Set_NMK(Adapter     : in Adapter_Type;
                     Pass_Phrase : in String;
                     Socket      : in Packet_Sockets.Thin.Socket_Type);

   function To_String(Adapter : in Adapter_Type) return String;

private

   type Adapter_Type is tagged
      record
         Network_Interface : Positive;
         MAC_Address       : Packet_Sockets.Thin.MAC_Address_Type;
         HFID              : HFID_String.Bounded_String;
      end record;

   procedure Create(Adapter           : in out Adapter_Type;
                    Network_Interface : in     Positive;
                    MAC_Address       : in     Packet_Sockets.Thin.MAC_Address_Type;
                    HFID              : in     HFID_String.Bounded_String);

end Power_Line_Adapter;
