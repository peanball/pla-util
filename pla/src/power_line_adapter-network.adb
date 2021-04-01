------------------------------------------------------------------------
--  pla-util - A powerline adapter utility
--  Copyright (C) 2016-2020 John Serock
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
with Ethernet.Datagram_Socket;

use type Ethernet.Datagram_Socket.Payload_Type;

package body Power_Line_Adapter.Network is

   function Discover(Socket : in Ethernet.Datagram_Socket.Socket_Type) return Power_Line_Adapter_Sets.Set is

      Adapter           : Adapter_Type;
      Adapters          : Power_Line_Adapter_Sets.Set(Capacity => Max_Adapters);
      Expected_Response : Ethernet.Datagram_Socket.Payload_Type(1 .. 9);
      MAC_Address       : Ethernet.MAC_Address_Type;
      Network_Interface : Positive;
      Request           : Ethernet.Datagram_Socket.Payload_Type(1 .. Ethernet.Datagram_Socket.Minimum_Payload_Size);
      Response          : Ethernet.Datagram_Socket.Payload_Type(1 .. 75);
      Response_Length   : Natural;

   begin

      Request := (16#01#, 16#70#, 16#a0#, 16#00#, 16#00#, 16#00#, 16#1f#, 16#84#, 16#01#, 16#a3#, 16#97#, 16#a2#, 16#55#, 16#53#, 16#be#, 16#f1#,
                  16#fc#, 16#f9#, 16#79#, 16#6b#, 16#52#, 16#14#, 16#13#, 16#e9#, 16#e2#, others => 16#00#);

      Socket.Send(Payload => Request,
                  To      => Ethernet.Broadcast_Address);

      Expected_Response := (16#02#, 16#71#, 16#a0#, 16#00#, 16#00#, 16#00#, 16#1f#, 16#84#, 16#01#);

      loop

         Socket.Receive(Payload        => Response,
                        Payload_Length => Response_Length,
                        From           => MAC_Address);

         if Response_Length = 0 then

            exit;

         end if;

         if Response(Expected_Response'Range) /= Expected_Response then

            raise Ethernet.Datagram_Socket.Socket_Error with Ethernet.Datagram_Socket.Message_Unexpected_Response;

         end if;

         Network_Interface := Positive(Response(10));

         Adapter.Create(Network_Interface => Network_Interface,
                        MAC_Address       => MAC_Address,
                        HFID              => Ethernet.Datagram_Socket.To_HFID_String(Payload => Response(12 .. Response_Length)));

         Adapters.Include(New_Item => Adapter);

      end loop;

      return Adapters;

   end Discover;

end Power_Line_Adapter.Network;
