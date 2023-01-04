/**
 * A noughts and crosses game I did at school I was about 16 years old.
 */

import javax.swing.*;
import java.util.*;

public class luffarschack {
        public static void main (String[]arg) {
                String pos, spelplan, playerA, playerB, player, Xin, Yin, in;
                char sp[][], bricka='O';
                int i, j, minX=0, minY=0, b, c, Xint, Yint, knapp = 0;
                boolean vinst=false, spStorlek=false;
                StringTokenizer ut;

                do{
                        playerA = JOptionPane.showInputDialog(null, "Spelare 1 (bricka O)");
                        if(playerA == null) System.exit(0);
                        playerB = JOptionPane.showInputDialog(null, "Spelare 2 (bricka X)");
                        if(playerB == null) System.exit(0);
                        if (playerB.equalsIgnoreCase(playerA)) {
                                JOptionPane.showMessageDialog(null, "Var god och välj olika namn.");
                        }
                } while (playerA.equalsIgnoreCase(playerB));

                player = playerA;

                while (knapp == 0){
                        do{
                                in = JOptionPane.showInputDialog("Ange spelplanens storlek.");
                                if(in == null) System.exit(0);
                                in  .trim();
                                in.toLowerCase();
                                Xint = in.lastIndexOf('x');
                                Yint = in.indexOf('x');
                                Xin = in.substring(Yint + 1);
                                Yin = in.substring(0,Xint);
                                Xint = Integer.parseInt(Xin);
                                Yint = Integer.parseInt(Yin);
                                if (Xint < 13 && Xint > 5 && Yint < 13 && Yint > 5){
                                        spStorlek = true;
                                }
                                else{
                                        spStorlek = false;
                                        JOptionPane.showMessageDialog(null, "Minimumhöjden är 6 och minimumbredden är 6.\n" +
                                                        "Maximumhöjden är 12 och maximumbredden är 12.");
                                }
                        } while(spStorlek == false);

                        sp = new char[Yint][Xint];

                        while(vinst == false) {
                                spelplan = "";
                                for (i=0; i<=Yint-1; i++) {
                                        for (j=0; j<=Xint-1; j++) {
                                                if (sp[i][j]!= 'O' && sp[i][j]!= 'X')
                                                        sp[i][j] = '\u0000';
                                                spelplan = spelplan + sp[i][j];
                                        }
                                        spelplan = spelplan + '\n';
                                }
                                spelplan = spelplan + '\n';
                                pos = JOptionPane.showInputDialog(spelplan + "\n" + player +", var god och ange kordinater.");
                                if (pos == null || pos == "exit") break;
                                ut = new StringTokenizer (pos);
                                minY = Integer.parseInt(ut.nextToken());
                                minX = Integer.parseInt(ut.nextToken());
                                minX = minX - 1;
                                minY = minY - 1;
                                if (sp[minY][minX] == 'O' || sp[minY][minX] == 'X'){
                                        JOptionPane.showMessageDialog(null, "Hörru " + player + "!\nDu får inte lägga över en existerande bricka.");
                                }
                                else{
                                        sp[minY][minX] = bricka;
                                        for(b=0; b<Yint; b++){
                                                for(c=0; c < Xint-3; c++){
                                                        if(sp[b][c] == bricka && sp[b][c+1] == bricka && sp[b][c+2] == bricka && sp[b][c+3] == bricka)
                                                                vinst = true;
                                                }
                                        }
                                        for(b=0; b<Yint-3; b++){
                                                for(c=0; c<Xint; c++){
                                                        if(sp[b][c] == bricka && sp[b+1][c] == bricka && sp[b+2][c] == bricka && sp[b+3][c] == bricka)
                                                                vinst = true;
                                                }
                                        }
                                        for(b=0; b<Yint-3; b++){
                                                for(c=0; c<Xint-3; c++){
                                                        if(sp[b][c] == bricka && sp[b+1][c+1] == bricka && sp[b+2][c+2] == bricka && sp[b+3][c+3] == bricka)
                                                                vinst = true;
                                                        if(sp[b][c+3] == bricka && sp[b+1][c+2] == bricka && sp[b+2][c+1] == bricka && sp[b+3][c] == bricka)
                                                                vinst = true;
                                                }
                                        }
                                        if (bricka == 'O')  bricka = 'X';
                                        else      bricka = 'O';
                                        if (player.equalsIgnoreCase(playerA))  player = playerB;
                                        else          player = playerA;  
                                }
                        }
                        if (bricka == 'O')  bricka = 'X';
                        else      bricka = 'O';
                        if (player.equalsIgnoreCase(playerA))  player = playerB;
                        else          player = playerA;
                        JOptionPane.showMessageDialog(null, "Grattis, "+ player +"!", "GRATTIS!", JOptionPane.INFORMATION_MESSAGE);
                        knapp = JOptionPane.showConfirmDialog(null, "Vill ni spela igen?", "Trött?", JOptionPane.YES_NO_OPTION);
                        if (knapp == 0){
                                vinst=false;
                                spStorlek=false;
                        }
                }
                JOptionPane.showMessageDialog(null, "Hej då " + playerA + " och " + playerB + "!", "Avsluta", JOptionPane.PLAIN_MESSAGE);
                System.exit(0);
        }
}
