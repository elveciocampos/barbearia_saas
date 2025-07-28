import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HorarioDonoBarbearia extends StatelessWidget {
  const HorarioDonoBarbearia({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 40,
              height: 40,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Image.network(
                'https://images.unsplash.com/photo-1549271568-e87e07c5406b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTM3MzcyMDZ8&ixlib=rb-4.1.0&q=80&w=1080',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, João!',
                  style: GoogleFonts.sora(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                    color: const Color(0xFF14181B),
                  ),
                ),
                Text(
                  'Administrador',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    color: const Color(0xFF677681),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF14181B),
                size: 24,
              ),
              onPressed: () {
                print('IconButton pressed ...');
              },
            ),
          ),
        ],
        centerTitle: false,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF0F2F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE3E7ED), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.store_rounded,
                        color: Color(0xFFF83B46),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Status da Barbearia',
                        style: GoogleFonts.sora(
                          fontWeight: FontWeight.w600,
                          fontSize: 32,
                          color: const Color(0xFF14181B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: const Color(0xFFE3E7ED),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Barbearia Clássica',
                            style: GoogleFonts.sora(
                              fontWeight: FontWeight.w500,
                              fontSize: 22,
                              color: const Color(0xFF14181B),
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6BBD78),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'ABERTA',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: Color(0xFF677681),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Horário: 08:00 - 18:00',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              color: const Color(0xFF677681),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            color: Color(0xFF677681),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hoje: Segunda-feira, 15 Jan',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              color: const Color(0xFF677681),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
