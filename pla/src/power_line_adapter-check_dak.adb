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

separate (Power_Line_Adapter)

function Check_DAK(Adapter     : in Adapter_Type;
                   Pass_Phrase : in String;
                   Socket      : in Ethernet.Datagram_Socket.Socket_Type) return Boolean is

   DAK               : Key_Type;
   Expected_Response : Ethernet.Datagram_Socket.Payload_Type(1 .. 12);
   Generated_DAK     : Key_Type;
   MAC_Address       : Ethernet.MAC_Address_Type;
   Request           : Ethernet.Datagram_Socket.Payload_Type(1 .. Ethernet.Datagram_Socket.Minimum_Payload_Size);
   Response          : Ethernet.Datagram_Socket.Payload_Type(1 .. Ethernet.Datagram_Socket.Minimum_Payload_Size);
   Response_Length   : Natural;

begin

   Validate_DAK_Pass_Phrase(Pass_Phrase      => Pass_Phrase,
                            Check_Min_Length => True);

   Request := (16#02#, 16#5c#, 16#a0#, 16#00#, 16#00#, 16#00#, 16#1f#, 16#84#, 16#02#, 16#09#, others => 16#00#);

   Adapter.Process(Request          => Request,
                   Socket           => Socket,
                   Response         => Response,
                   Response_Length  => Response_Length,
                   From_MAC_Address => MAC_Address);

   Expected_Response := (16#02#, 16#5d#, 16#a0#, 16#00#, 16#00#, 16#00#, 16#1f#, 16#84#, 16#02#, 16#04#, 16#01#, 16#00#);

   if Response_Length < 16 or else Response(Expected_Response'Range) /= Expected_Response then

      raise Ethernet.Datagram_Socket.Socket_Error with Ethernet.Datagram_Socket.Message_Unexpected_Response;

   end if;

   DAK(1) := Response(16);
   DAK(2) := Response(15);
   DAK(3) := Response(14);
   DAK(4) := Response(13);

   Request := (16#02#, 16#5c#, 16#a0#, 16#00#, 16#00#, 16#00#, 16#1f#, 16#84#, 16#03#, 16#0a#, others => 16#00#);

   Adapter.Process(Request          => Request,
                   Socket           => Socket,
                   Response         => Response,
                   Response_Length  => Response_Length,
                   From_MAC_Address => MAC_Address);

   Expected_Response := (16#02#, 16#5d#, 16#a0#, 16#00#, 16#00#, 16#00#, 16#1f#, 16#84#, 16#03#, 16#04#, 16#01#, 16#00#);

   if Response_Length < 16 or else Response(Expected_Response'Range) /= Expected_Response then

      raise Ethernet.Datagram_Socket.Socket_Error with Ethernet.Datagram_Socket.Message_Unexpected_Response;

   end if;

   DAK(5) := Response(16);
   DAK(6) := Response(15);
   DAK(7) := Response(14);
   DAK(8) := Response(13);

   Request := (16#02#, 16#5c#, 16#a0#, 16#00#, 16#00#, 16#00#, 16#1f#, 16#84#, 16#04#, 16#0b#, others => 16#00#);

   Adapter.Process(Request          => Request,
                   Socket           => Socket,
                   Response         => Response,
                   Response_Length  => Response_Length,
                   From_MAC_Address => MAC_Address);

   Expected_Response := (16#02#, 16#5d#, 16#a0#, 16#00#, 16#00#, 16#00#, 16#1f#, 16#84#, 16#04#, 16#04#, 16#01#, 16#00#);

   if Response_Length < 16 or else Response(Expected_Response'Range) /= Expected_Response then

      raise Ethernet.Datagram_Socket.Socket_Error with Ethernet.Datagram_Socket.Message_Unexpected_Response;

   end if;

   DAK(9)  := Response(16);
   DAK(10) := Response(15);
   DAK(11) := Response(14);
   DAK(12) := Response(13);

   Request := (16#02#, 16#5c#, 16#a0#, 16#00#, 16#00#, 16#00#, 16#1f#, 16#84#, 16#05#, 16#0c#, others => 16#00#);

   Adapter.Process(Request          => Request,
                   Socket           => Socket,
                   Response         => Response,
                   Response_Length  => Response_Length,
                   From_MAC_Address => MAC_Address);

   Expected_Response := (16#02#, 16#5d#, 16#a0#, 16#00#, 16#00#, 16#00#, 16#1f#, 16#84#, 16#05#, 16#04#, 16#01#, 16#00#);

   if Response_Length < 16 or else Response(Expected_Response'Range) /= Expected_Response then

      raise Ethernet.Datagram_Socket.Socket_Error with Ethernet.Datagram_Socket.Message_Unexpected_Response;

   end if;

   DAK(13) := Response(16);
   DAK(14) := Response(15);
   DAK(15) := Response(14);
   DAK(16) := Response(13);

   Generated_DAK := Generate_DAK(Pass_Phrase => Pass_Phrase);

   return Generated_DAK = DAK;

end Check_DAK;
