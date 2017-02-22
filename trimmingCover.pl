#!/usr/bin/perl

use GD;
use Jcode;
use utf8;
binmode STDIN, ':encoding(cp932)';
binmode STDOUT, ':encoding(cp932)';
binmode STDERR, ':utf8';

$number_of_files=@ARGV;

$counter = 0;
$totalyokos = 0;
$totaltates = 0;
$out_of_work = 0;

for ($i=0; $i<$number_of_files; $i++){

    open(OLD,$ARGV[$i]) || die "$!";

    $oldImage= newFromJpeg GD::Image(\*OLD) || "Cannot make old image object\n";

    ($x,$y) = $oldImage->getBounds();


    $ideal_yoko = int($y* 1145 / 1595);
    #$ideal_yoko = int($y* 848/1200);
    $handan_rate = $x/$ideal_yoko;

    if ( $handan_rate < 1.1){

	$totalyokos += $x;
	$totaltates += $y;
	$counter ++;
    }
    close OLD;
}

if ($counter/$number_of_files < 0.9) {
    $out_of_work = 1;
}
if ($counter ==0){
    $counter = 1;
}

$av_x = $totalyokos/$counter;
$av_y = $totaltates/$counter;


for ($i = 0; $i < $number_of_files; $i++){
  open(OLD,$ARGV[$i]) || die "$!";

  $oldImage = newFromJpeg GD::Image(\*OLD) || "Cannot make old image object\n";
  @bound = $oldImage->getBounds();



  $filename = $ARGV[$i];
  @names = split(/\./, $filename);

  $is_truecolor = $oldImage->isTrueColor();

  $yoko = $bound[0];
  $tate = $bound[1];
  if ($out_of_work == 1){
    $av_x = 1145;
    $av_y = 1595;
  }
  $ideal_yoko = int($tate/1.42);  
  $ideal_yoko2 = int($tate/1.55); 

  $tateyoko_rate = $yoko/$tate;
  $ideal_rate = $yoko/$ideal_yoko;

  $center_position = int($yoko/2);
  if ($is_truecolor == 0 ){

    if ($ideal_rate > 0.9 && $ideal_rate < 1.04){ 
      $cutImage = &cutRightByRate($oldImage, $ideal_yoko2, $tate, 1.000,0 );
      $trueX = &findBorderRight($cutImage);
      if ($trueX > 1){
        &cutTrueRight($cutImage, $trueX,1);
      }
      $trueX2 = &findBorderRight2($cutImage);
      if ($trueX2 > 3){
        &cutTrueRight($centImage, $trueX2,2);
      }

      next;
    }elsif ($ideal_rate >= 1.04 && $ideal_rate < 1.3){
      $cutImage = &cutRightByRate($oldImage, $ideal_yoko, $tate, 1.000,0 );
      $trueX = &findBorderRight($cutImage);
      if ($trueX > 1){
        &cutTrueRight($cutImage, $trueX,1);
      }
      next;
    }elsif ($ideal_rate >= 3.07){
      
      $centImage = &assumeCenterByRate($oldImage, $ideal_yoko, $tate,$center_position,1.067 ,0);
      $trueX = &findBorderRight($centImage);
      if ($trueX > 1){
        &cutTrueRight($centImage, $trueX,1);
      }
      next;

    }elsif ($ideal_rate >= 2.95 && $ideal_rate < 3.07){
      $centImage = &assumeCenterByRate($oldImage, $ideal_yoko2, $tate,$center_position,1.067 ,0);
      $trueX = &findBorderRight($centImage);
      if ($trueX > 1){
        &cutTrueRight($centImage, $trueX,1);
      }
      $trueX2 = &findBorderRight2($centImage);
      if ($trueX2 > 3){
        &cutTrueRight($centImage, $trueX2,2);
      }

      next;
      

    }elsif ($ideal_rate >= 2.04 && $ideal_rate < 2.95){

      $cutImage = &cutRightByRate($oldImage, $ideal_yoko, $tate, 1.000,0);
      &cutRightByRate($oldImage, $ideal_yoko, $tate, 0.983,1);
      $trueX = &findBorderRight($cutImage);
      if ($trueX > 1){
        &cutTrueRight($cutImage, $trueX,2);
      }
      next;

    }elsif ($ideal_rate > 1.90 && $ideal_rate < 2.04){

      $cutImage = &cutRightByRate($oldImage, $ideal_yoko2, $tate, 1.000,0);

      $trueX = &findBorderRight($cutImage);
      if ($trueX > 1){
        &cutTrueRight($cutImage, $trueX,1);
      }
      $trueX2 = &findBorderRight2($cutImage);
      if ($trueX2 > 3){
        &cutTrueRight($cutImage, $trueX2,2);
      }
      $trueX3 = &findBorderRight3($cutImage);
      if ($trueX3 > 3 && $trueX3 != $trueX2){
        &cutTrueRight($cutImage, $trueX3,3);
      }

      

      next;
      
    }elsif ($ideal_rate >= 1.65 && $ideal_rate <= 1.90){

      $cutWidth = $ideal_yoko * 1.134;
      print "$cutWidth , $tate をまず切り取ります\n";
      $cutImage = &cutLeft($oldImage, $cutWidth, $tate);
      $cutImage2 = &cutRightByRate($cutImage, $ideal_yoko, $tate, 1.0, 0);
      $trueX = &findBorderRight($cutImage2);
      if ($trueX > 1){
        &cutTrueRight($cutImage2,$trueX,1);
      }
      next;      

    }elsif ($ideal_rate > 1.3 && $ideal_rate <= 1.65){

      $cutWidth = $ideal_yoko2 * 1.134;
      $cutImage = &cutLeft($oldImage, $cutWidth, $tate);
      $cutImage2 = &cutRightByRate($cutImage, $ideal_yoko2, $tate, 1.0, 0);

      $trueX = &findBorderRight($cutImage2);
      if ($trueX > 1){
        &cutTrueRight($cutImage2,$trueX,1);
      }
      $trueX2 = &findBorderRight2($cutImage2);
      if ($trueX2 > 3){
        &cutTrueRight($cutImage2, $trueX2,2);
      }

      $trueX3 = &findBorderRight3($cutImage2);
      if ($trueX3 > 3 && $trueX3 != $trueX2){
        &cutTrueRight($cutImage2, $trueX3,3);
      }

      
      next;      
      
    }

  }elsif ($is_truecolor == 1 &&  $ideal_rate > 1.85 && $ideal_rate <2.0){
    $newImage = new GD::Image($ideal_yoko,$tate)|| die "cannot make new image object\n";
    $newImage->copy($oldImage, 0,0,0,0,$ideal_yoko2, $tate);
    print $newfilename0," type: mono 2in1\n";
    open NEW, ">$newfilename0";
    binmode NEW;
    print NEW $newImage->jpeg;
    close NEW;

    $newImage2 = new GD::Image($ideal_yoko,$tate)|| die "cannot make new image object\n";
    $newImage2->copy($oldImage, 0,0,$yoko-$ideal_yoko2,0,$ideal_yoko2, $tate);
    print $newfilename1," type: mono 2in1\n";
    open NEW2, ">$newfilename1";
    binmode NEW2;
    print NEW2 $newImage2->jpeg;
    close NEW2;
  }

  close OLD;
}


sub findBorderRight{
  $image = $_[0];
  $flag = 0;
  $counter = 0;
  $thU = 50;
  $thB = 50;

  ($fx , $fy) = $image->getBounds();

  $targetY = $fy -1;
  while ($flag == 0){

    $index = $image->getPixel($fx-$counter-1, $targetY);
    ($r,$g,$b) = $image->rgb($index);

    if ($counter != 0){

      if(abs($r -$pr)<$thU && abs($g-$pg) < $thU && abs( $b - $pb)<$thU){
        $flag =0;
      }else{
        $flag = 1;
      }
    }

    $counter++;
    $pr = $r;
    $pg = $g;
    $pb = $b;
    if($counter > $fx/12){
      $flag = 1;
    }
  }
  if ($counter > $fx / 12){
    return(0);
  }else{
    return ($counter*1.1);
  }
}

sub findBorderRight2{
  $image = $_[0];
  $flag = 0;
  $counter = 0;
  $totalGray = 0;
  $tempGray = 0;
  $th = 50;
  ($fx , $fy) = $image->getBounds();
  $targetY = $fy -1;
  $start = $fy * 0.3;
  $end = $fy * 0.7;
  while ($flag == 0){
    for($j = $fx-1; $j > $fx*0.9; $j--){
      $counter++;
      $totalGray = 0;
      for( $i = $start; $i < $end ; $i++){
        $index = $image->getPixel($j, $i);
        ($r,$g,$b) = $image->rgb($index);
        $tempGray = (77*$r+150*$g+29*$b)/256;

        $totalGray += $tempGray;
      }
      $averageGray = $totalGray /($end-$start);

      if($averageGray > 195 ){

        $flag =0;
      }else{
        $flag = 1;
        last;
      }
    }
    $flag = 1;
  }

  if ($counter > $fx *0.1){
    return(0);
  }else{
    return ($counter);
  }
}


sub findBorderRight3{
  $image = $_[0];
  $flag = 0;
  $counter = 0;
  $totalGray = 0;
  $tempGray = 0;
  $th = 50;
  ($fx , $fy) = $image->getBounds();
  $targetY = $fy -1;
  $start = $fy * 0.3;
  $end = $fy * 0.7;
  while ($flag == 0){
    for($j = $fx-1; $j > $fx*0.9; $j--){
      $counter++;
      $totalGray = 0;
      for( $i = $start; $i < $end ; $i++){
        $index = $image->getPixel($j, $i);
        ($r,$g,$b) = $image->rgb($index);
        $tempGray = (77*$r+150*$g+29*$b)/256;

        $totalGray += $tempGray;
      }
      $averageGray = $totalGray /($end-$start);

      if($averageGray > 195 ){

        $flag =0;
      }else{
        $flag = 1;
        last;
      }
    }
    $flag = 1;
  }

  if ($counter > $fx *0.1){
    return(0);
  }else{
    return ($counter);
  }
}



sub findFoldLeft{

  $image = $_[0];
  $threshold = 12;
  ($fx , $fy) = $image->getBounds();

  $foldWidthRange = $fy*14/845/2;



  for( $i = 0; $i < $fY/2; $i++){
    $counter = 0;
    $averageGray = 0;
    $totalGray = 0;
    for( $j = $i; $j < $i+$foldWidthRange; $j ++){
      for( $k = 0; $k < $fT; $k++){
        $counter++;
        $index = $image->getPixel($j, $k);
        ($r,$g,$b) = $image->rgb($index);
        $tempGray = (77*$r+150*$g+29*$b)/256;
        $totalGray += $tempGray;
      }
    }
    $averageGray = $totalGray / $counter;
    printf("averageGray: %4f\n", $averageGray);
    if( $i!= 0){
      if( $averageGray+$threshold < $firstGray or $averageGray > $firstGray+$threshold){
        printf("折り目?-- %d\n", $i);
        last;
      }
    }else{
      $firstGray = $averageGray;
      print"firstGray: $firstGray\n";
    }
    $prevGray = $averageGray;
  }
  return($i);
}


sub findBorderLeft{
  ($image , $writeWidth, $writeHeight)= @_;
  $threshold = 0.3;
  ($fY , $fT) = $image->getBounds();

  $foldWidthRange = $fY*14/845/2;

  for( $i = 0; $i < $fY/2; $i+=3){
    $counter = 0;
    $averageGray = 0;
    $totalGray = 0;
    for( $j = $i; $j < $i+$foldWidthRange; $j ++){
      for( $k = 0; $k < $fT; $k++){
        $counter++;
        $index = $image->getPixel($j, $k);
        ($r,$g,$b) = $image->rgb($index);
        $tempGray = (77*$r+150*$g+29*$b)/256;
        $totalGray += $tempGray;
      }
    }
    $averageGray = $totalGray / $counter;
    if( $i!= 0){
      if( abs($averageGray -  $firstGray) > $firstGray*$threshold){
        last;
      }
    }else{
      $firstGray = $averageGray;
    }
    $prevGray = $averageGray;
  }
  return($i);
}

sub cutRightByRate{
  $image = $_[0];
  $width = $_[1];
  $height = $_[2];
  $rate = $_[3];
  $number = $_[4];
  $newImage = new GD::Image($width*$rate,$height)|| die "cannot make new image object\n";
  $newImage->copy($image, 0,0,0,0,$width*$rate, $height);
  &fileWriteOut($newImage, $number);
  return($newImage);

}

sub assumeCenterByRate{
  $image = $_[0];
  $width = $_[1];
  $height = $_[2];
  $center = $_[3];
  $rate = $_[4];
  $number = $_[5];
  $newImage = new GD::Image($width,$height)|| die "cannot make new image object\n";
  $newImage->copy($image, 0,0,$center - int($width*$rate),0,$width, $height);
  &fileWriteOut($newImage, $number);
  return($newImage);
}

sub cutTrueRight{
  $image = $_[0];
  $trueX = $_[1];
  $number = $_[2];
  ($width , $height) = $image->getBounds();
  $newImage3 = new GD::Image($width-$trueX,$height)|| die "cannot make new image object\n";
  $newImage3->copy($image, 0,0,0,0,$width-$trueX, $height);
  &fileWriteOut($newImage3, $number);
  return($newImage3);
}

sub cutLeft{
  $image = $_[0];
  $width = $_[1];
  $height = $_[2];
  
  ($owidth , $oheight) = $image->getBounds();
  $newImage = new GD::Image($width,$height)|| die "cannot make new image object\n";
  $newImage->copy($image, 0,0,$owidth - $width, 0, $width, $height);
  return($newImage);
}

sub fileWriteOut{
  $writeImage = $_[0];
  $writeNumber = $_[1];
  $nFilename = $names[0]."__".$writeNumber.".".$names[1];
  print $nFilename;
  open NEW, ">$nFilename";
  binmode NEW;
  print NEW $writeImage->jpeg;
  close NEW;

}
